import 'package:AttendanceApp/screens/splash.dart';
import 'package:flutter/material.dart';
import '../services/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OutletChooser extends StatefulWidget {
  @override
  createState() => _OutletChooserState();
}

class _OutletChooserState extends State<OutletChooser> {
  AuthService auth = AuthService();
  @override
  void initState() {
    getOutlet();
    initOutlets();
    super.initState();
  }

  getOutlet() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String outlet = sharedPreferences.getString('Outlet');
    print(outlet);
    if (outlet != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InitialScreen(),
        ),
      );
    }
  }

  List<String> outlets = new List<String>();

  List<String> names = new List<String>();
  initOutlets() {
    for (var i = 1; i <= 150; i++) {
      outlets.add(i.toString());
    }
    for (var i = 'A'.codeUnitAt(0), x = 0; x < outlets.length; i++, x++) {
      names.add(outlets[x] + ' - ' + String.fromCharCode(i));
      if (String.fromCharCode(i) == 'Z') {
        i = 'A'.codeUnitAt(0);
      }
    }
  }

  String out = '1';
  String val = '1 - A';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[900],
        body: Container(
          padding: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Choose outlet',
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
              DropdownButton<String>(
                isExpanded: true,
                focusColor: Colors.white,
                style: TextStyle(color: Colors.black),
                value: val,
                hint: Text(
                  out,
                  style: TextStyle(color: Colors.white),
                ),
                items: names.map((String outlet) {
                  return DropdownMenuItem<String>(
                    value: outlet,
                    child: Text(outlet),
                  );
                }).toList(),
                onChanged: (value) {
                  var temp = value.split(' -').first;
                  print(temp);
                  setState(() {
                    out = temp;
                    val = value;
                  });
                },
              ),
              FlatButton(
                onPressed: () async {
                  SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  await sharedPreferences.setString('Outlet', out);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InitialScreen(),
                    ),
                  );
                },
                child: Text('Submit'),
                color: Colors.red[400],
              ),
            ],
          ),
        ));
  }
}
