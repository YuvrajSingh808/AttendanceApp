import 'package:AttendanceApp/screens/login.dart';
import 'package:AttendanceApp/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  SettingScreen({Key key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            trailing: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
              AuthService auth = AuthService();
              auth.user.listen((User user) async {
                if (user != null) {
                  await auth.auth.signOut();
                  SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  await sharedPreferences.remove('Outlet');
                  print(
                    sharedPreferences.getString('Outlet'),
                  );
                }
                // TfSpeech().close();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              });
            },
            // tileColor: Colors.grey[50],
          ),
          ListTile(
            title: Text('About'),
            trailing: Icon(Icons.info_outline),
            onTap: () => showAboutDialog(
              context: context,
              applicationVersion: '1.0.0',
              applicationName: 'Attendance App',
              children: [
                Text('Developer: Yuvraj Singh'),
                Text('Developer contact: yuvrajsingh808@gmail.com'),
                SizedBox(height: 15,),
                Text('Firm: Naaniz')
              ]
            ),
          ),
        ],
      ),
    );
  }
}
