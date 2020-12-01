class Employee {
  String name;
  String id;
  String phone;
  String email;
  String outletId;
  bool outletAdmin;
  bool superAdmin;
  List<dynamic> markedInAt;
  List<dynamic> markedOutAt;
  int lastMarkedIn;
  int lastMarkedOut;
  int totalPresentDays;
  int hoursWorked;
  List faceData;
  Employee(
      {this.name,
      this.id,
      this.phone,
      this.email,
      this.outletId,
      this.faceData}) {
    outletAdmin = false;
    superAdmin = false;
  }
  Employee.lastPresentFromMap(Map data) {
    lastMarkedIn = data['Last Marked in'] ?? -1;
    lastMarkedOut = data['Last Marked out'] ?? -1;
    totalPresentDays = data['Total present days'] ?? 0;
    markedInAt = data['Marked in at'] ?? [-1];
    markedOutAt = data['Marked out at'] ?? [-1];
    hoursWorked = data['Hours worked'];
  }
  Employee.fromMap(Map data) {
    name = data['Name'] ?? '';
    id = data['Employee ID'] ?? '';
    phone = data['Phone'] ?? '';
    email = data['Email'] ?? '';
    outletId = data['Outlet ID'] ?? '';
    outletAdmin = data['Outlet admin'] ?? false;
    superAdmin = data['Super admin'] ?? false;
    faceData = data['Face data'] ?? [];
  }
}
