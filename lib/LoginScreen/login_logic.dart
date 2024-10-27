import 'package:firebase_auth/firebase_auth.dart';

import '../helpers/error_provider.dart';

class LoginLogic {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> login({
    required String email,
    required String password,
    required ErrorProvider errorProvider,
  }) async {
    try {
      errorProvider.clearErrors(); // Clear errors before login attempt

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Handle successful login navigation or other logic here.
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          errorProvider.setEmailError("User not found");
        } else if (e.code == 'wrong-password') {
          errorProvider.setPasswordError("Incorrect password");
        } else {
          errorProvider.setEmailError("Login failed. Please try again.");
        }
      }
    }
  }
}
