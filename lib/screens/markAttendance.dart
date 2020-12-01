import 'dart:async';
import 'package:AttendanceApp/screens/home.dart';
import 'package:AttendanceApp/services/db.dart';
import 'package:AttendanceApp/services/facenet.service.dart';
import 'package:AttendanceApp/services/models.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MarkAttendance extends StatefulWidget {
  final CameraDescription cameraDescription;
  final List<dynamic> currPredictedData;
  final String choice;
  MarkAttendance(
      {Key key, this.currPredictedData, this.cameraDescription, this.choice})
      : super(key: key);

  @override
  _MarkAttendanceState createState() => _MarkAttendanceState();
}

class _MarkAttendanceState extends State<MarkAttendance> {
  FaceNetService faceNetService = new FaceNetService();
  Employee employee;
  String id;
  DatabaseService databaseService = new DatabaseService();
  double height = 50;
  Timer timer;
  @override
  void initState() {
    super.initState();
    timer = Timer(Duration(seconds: 10), () {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Couldn\'t match face ID'),
            content: Text('Please contact your admin'),
          );
        },
      );
      timer = Timer(Duration(seconds: 3), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(cameraDescription: widget.cameraDescription),),
          (Route<dynamic> route) => false,
        );
      });
    });
  }

  @override
  void dispose() {
    while (timer.isActive) {
      timer.cancel();
    }
    super.dispose();
  }

  Future<bool> assignId() async {
    id = await faceNetService.predict(widget.choice);
    print(id);
    if (id != null) {
      await getEmployee(id);
      return true;
    }
    return false;
  }

  Future<void> getEmployee(String id) async {
    var data =
        await FirebaseFirestore.instance.collection('Users').doc(id).get();
    employee = Employee.fromMap(data.data());
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(219, 213, 213, 1),
      body: FutureBuilder(
        future: assignId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data == true) {
            timer = Timer(Duration(seconds: 5), () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(
                      cameraDescription: widget.cameraDescription,
                    ),
                  ),
                  (Route<dynamic> route) => false);
            });
            return Padding(
              padding: const EdgeInsets.all(18.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 80,
                    ),
                    SvgPicture.asset(
                      'assets/avatar.svg',
                      height: 150,
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    FieldWidget(
                      field: 'Employee name',
                      value: employee.name ?? '',
                    ),
                    FieldWidget(
                      field: 'Employee ID',
                      value: employee.id ?? '',
                    ),
                    FieldWidget(
                      field: 'Phone',
                      value: employee.phone ?? '',
                    ),
                    FutureBuilder(
                      future: widget.choice == 'markin'
                          ? databaseService.markIn(employee)
                          : databaseService.markOut(employee),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          print(snapshot.data);
                          if (snapshot.data[0] is Timestamp) {
                            DateTime data = DateTime.fromMillisecondsSinceEpoch(
                                snapshot.data[0].millisecondsSinceEpoch);
                            if (data.day != DateTime.now().day) {
                              data = DateTime.now();
                            }
                            return Column(
                              children: [
                                FieldWidget(
                                  field:
                                      'Attendance marked ${widget.choice == 'markin' ? 'in' : 'out'} at:',
                                  value: time(data.hour) +
                                      ':' +
                                      time(data.minute) +
                                      ':' +
                                      time(data.minute),
                                  // '${TimeOfDay.fromDateTime(DateTime.now()).hour}:${TimeOfDay.fromDateTime(DateTime.now()).minute < 10 ? '0${TimeOfDay.fromDateTime(DateTime.now()).minute}' : 'TimeOfDay.fromDateTime(DateTime.now()).minute'}'),
                                  // data.
                                ),
                                widget.choice == 'markout' ||
                                        snapshot.data[1] != -1
                                    ? FieldWidget(
                                        field: 'Hours worked',
                                        value: '${snapshot.data[1]}',
                                      )
                                    : Container(),
                              ],
                            );
                          } else
                            return Container();
                        } else {
                          return Column(
                            children: [
                              Center(
                                child: Text('Marking attendance'),
                              ),
                              Image.asset('assets/loading.gif'),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          // else if(Future.){

          // }
          else {
            return Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Loader(),
                    Text(
                      'Verifying face data..',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(36, 41, 92, 1),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  String time(int time) {
    if (time < 10) {
      return '0$time';
    } else
      return '$time';
  }
}

class Loader extends StatefulWidget {
  Loader({
    Key key,
  }) : super(key: key);
  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  double height = 70;
  double width = 200;
  int temp = 0;
  @override
  Widget build(BuildContext context) {
    if (temp == 0) {
      setState(() {
        temp = 1;
      });
    }
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: SvgPicture.asset(
        'assets/verify.svg',
      ),
      height: height,
      onEnd: () {
        setState(() {
          height = height == 70 ? 80 : 70;
        });
      },
    );
  }
}

class FieldWidget extends StatelessWidget {
  final String field, value;
  const FieldWidget({
    Key key,
    @required this.field,
    @required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Text(
              field,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(36, 41, 92, 1)),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border(
              bottom: BorderSide(color: Color.fromRGBO(36, 41, 92, 1)),
            )),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
