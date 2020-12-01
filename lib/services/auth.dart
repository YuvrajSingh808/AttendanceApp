import 'package:AttendanceApp/services/db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/services.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseService databaseService = DatabaseService();

  Stream<User> get user => auth.authStateChanges();

  Future<void> signIn(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Text(e.message),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Retry'),
                color: Colors.blue,
              )
            ],
          );
        },
      );
    }
    

  }
}
