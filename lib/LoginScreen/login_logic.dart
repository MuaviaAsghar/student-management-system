import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginLogic {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Sign in with Firebase Authentication
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Check if user exists in Firestore
      final userDoc =
          await _firestore.collection('users').doc(email.trim()).get();

      // If the user document doesn't exist, create it with role 'admin'
      String role;
      if (!userDoc.exists) {
        await _firestore.collection('users').doc(email.trim()).set({
          'email': email.trim(),
          'role': 'admin', // Default role
        });
        role = 'admin';
      } else {
        role = userDoc.data()?['role'] ??
            'student'; // Default to student if role is not set
      }

      // Navigate to appropriate screen based on role
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/adminHomeScreen');
      } else {
        Navigator.pushReplacementNamed(context, '/studentHomeScreen');
      }
    } catch (e) {
      log("Error during login: $e");
      _handleLoginError(e, context);
    }
  }

  void _handleLoginError(dynamic error, BuildContext context) {
    String errorMessage = "Login failed. Please try again.";
    if (error is FirebaseAuthException) {
      if (error.code == 'user-not-found') {
        errorMessage = "User not found";
      } else if (error.code == 'wrong-password') {
        errorMessage = "Incorrect password";
      }
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(errorMessage)));
  }
}
