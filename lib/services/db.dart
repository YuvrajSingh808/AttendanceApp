import 'package:AttendanceApp/shared/sharedFunctions.dart';
import '../services/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  String outletId;
  Future<String> setOutlet() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    outletId = sharedPreferences.getString('Outlet');
    return outletId;
  }

  String attendanceRefName =
      getMonthName(DateTime.now().month) + DateTime.now().year.toString();

  final CollectionReference userRef =
      FirebaseFirestore.instance.collection('Users');

  Future<List> markIn(Employee user) async {
    String string = await setOutlet() + '_' + attendanceRefName;
    print(string);
    CollectionReference attendanceRef =
        FirebaseFirestore.instance.collection(string);
    Employee temp;
    try {
      DocumentSnapshot snapshot = await attendanceRef.doc(user.id).get();
      temp = Employee.lastPresentFromMap(snapshot.data());
      if (temp.lastMarkedIn < DateTime.now().day) {
        await attendanceRef.doc(user.id).update({
          'Last Marked in': DateTime.now().day,
          'Marked in at': FieldValue.arrayUnion([DateTime.now()]),
          'Is Currently working': true,
          'Hours worked': -1
        });
        return [Timestamp.now(), -1];
      }
      print('object');
      return [temp.markedInAt.last, -1];
    } catch (e) {
      await attendanceRef.doc(user.id).set({
        'Last Marked in': DateTime.now().day,
        'Marked in at': FieldValue.arrayUnion([DateTime.now()]),
        'Is Currently working': true,
        'Hours worked': -1
      });
      return [0, -1];
    }
  }

  Future<List> markOut(Employee user) async {
    String string = user.outletId + '_' + attendanceRefName;
    CollectionReference attendanceRef =
        FirebaseFirestore.instance.collection(string);

    DocumentSnapshot snapshot = await attendanceRef.doc(user.id).get();
    snapshot.data().isEmpty ? print('Empty') : print('Not empty');
    Employee temp = Employee.lastPresentFromMap(snapshot.data());
    // List<DateTime> array = data['Marked in at'];
    Timestamp time1 = temp.markedInAt.last;
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(time1.millisecondsSinceEpoch);
    int hoursWorked;
    if (temp.hoursWorked == -1)
      hoursWorked = DateTime.now().difference(dateTime).inHours;
    else
      hoursWorked = temp.hoursWorked;
    try {
      if (temp.lastMarkedOut < DateTime.now().day) {
        await attendanceRef.doc(user.id).update({
          'Last Marked out': DateTime.now().day,
          'Total present days': hoursWorked >= 8
              ? FieldValue.increment(1)
              : FieldValue.increment(0),
          'Marked out at': FieldValue.arrayUnion([DateTime.now()]),
          'Is Currently working': false,
          'Hours worked': hoursWorked,
        });
      }
    } catch (e) {
      await attendanceRef.doc(user.id).set({
        'Last Marked out': DateTime.now().day,
        'Total present days': hoursWorked >= 8
            ? FieldValue.increment(1)
            : FieldValue.increment(0),
        'Marked out at': FieldValue.arrayUnion([DateTime.now()]),
        'Is Currently working': false,
        'Hours worked': hoursWorked,
      });
    }
    return [temp.markedOutAt.last, hoursWorked];
  }

  Future<List<dynamic>> getFaceDataList(String choice) async {
    QuerySnapshot users =
        await userRef.where('Outlet ID', isEqualTo: outletId).get();
    QuerySnapshot attendance = await FirebaseFirestore.instance
        .collection(attendanceRefName)
        .where('Is Currently working',
            isEqualTo: choice == 'markin' ? true : false)
        .get();

    List<Employee> employees = new List();
    for (var item in users.docs) {
      employees.add(Employee.fromMap(item.data()));
    }

    int i = 0;
    List<Map<String, dynamic>> data = new List();

    Map<String, dynamic> temp = new Map();

    for (var employee in employees) {
      if (attendance.docs.length == 0 || employee.id != attendance.docs[i].id) {
        temp['${employee.id}'] = employee.faceData;
        data.add(temp);
      }
      i++;
    }

    return data;
  }

  Future<void> updateUserData(Employee user) async {
    DocumentReference doc = userRef.doc(user.id);
    return doc.set(
      {
        'Name': user.name,
        'Employee ID': user.id,
        'Phone': user.phone,
        'Outlet ID': user.outletId,
        'Outlet admin': user.outletAdmin,
        'Super admin': user.superAdmin,
        'Face data': user.faceData,
        'Email': user.email
      },
    );
  }

  Future<List<String>> getAllIds() async {
    final QuerySnapshot result = await userRef.get();
    final List<DocumentSnapshot> docs = result.docs;
    List<String> ids = new List();
    for (var i = 0; i < docs.length; i++) {
      ids.add(docs[i].id);
    }
    return ids;
  }

  // singleton boilerplate
  static final DatabaseService _cameraServiceService =
      DatabaseService._internal();

  factory DatabaseService() {
    return _cameraServiceService;
  }
  // singleton boilerplate
  DatabaseService._internal();
}
