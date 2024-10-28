import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LogoutLogic {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/landingScreen');
  }
}
