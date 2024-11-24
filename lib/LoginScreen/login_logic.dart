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

      // Retrieve user ID from authentication
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw FirebaseAuthException(code: 'user-not-found');
      }

      // Check if user exists in 'admins' or 'students' collection
      DocumentSnapshot<Map<String, dynamic>> userDoc;
      bool isAdmin = false;

      // Try to find the user in 'admins' subcollection
      userDoc = await _firestore
          .collection('users')
          .doc('admins')
          .collection(email.trim())
          .doc("admin")
          .get();

      // If not found in 'admins', check in 'students'
      if (!userDoc.exists) {
        userDoc = await _firestore
            .collection('users')
            .doc('students')
            .collection(email.trim())
            .doc(userId)
            .get();
      } else {
        isAdmin = true;
      }

      // If user is found, navigate based on role
      if (userDoc.exists) {
        if (isAdmin) {
          Navigator.pushReplacementNamed(context, '/adminHomeScreen');
        } else {
          Navigator.pushReplacementNamed(context, '/studentHomeScreen');
        }
      } else {
        // Handle the case where the user doesn't exist in either collection
        _showErrorSnackbar(context, "User not found in the database.");
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
    _showErrorSnackbar(context, errorMessage);
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
