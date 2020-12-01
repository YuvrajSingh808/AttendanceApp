import 'package:AttendanceApp/screens/OutletChooser.dart';
import 'package:AttendanceApp/screens/splash.dart';
import 'package:flutter/material.dart';
import '../services/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthService auth = AuthService();
  final TextEditingController email = new TextEditingController();

  final TextEditingController pass = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String outlet;
  // String roll;
  @override
  void initState() {
    super.initState();
    outletgiver();
    auth.user.listen((user) {
      if (user != null && outlet != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InitialScreen(),
          ),
        );
      }
    });
  }

  outletgiver() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    outlet = sharedPreferences.getString('Outlet');
    print(outlet);
  }

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
              'Outlet Admin login',
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),
            Container(
              child: Form(
                key: _formKey,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextFormField(
                      controller: email,
                      decoration: new InputDecoration(
                        hintText: 'ABCD1234',
                        labelText: 'Email',
                        fillColor: Colors.grey[300],
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      // color
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      obscureText: true,
                      controller: pass,
                      decoration: new InputDecoration(
                        // hintText: 'ABCD1234',

                        labelText: 'Password',
                        fillColor: Colors.grey[300],
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      // color
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: FlatButton.icon(
                padding: EdgeInsets.all(30),
                color: Colors.red,
                onPressed: () async {
                  await auth.signIn(email.text, pass.text, context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OutletChooser(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.verified_user,
                  color: Colors.white,
                ),
                label: Text(
                  'Sign in',
                  // textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
