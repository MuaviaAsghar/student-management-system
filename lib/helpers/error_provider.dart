import 'package:flutter/material.dart';

class ErrorProvider extends ChangeNotifier {
  String? _emailError;
  String? _passwordError;

  String? get emailError => _emailError;
  String? get passwordError => _passwordError;

  void setEmailError(String? message) {
    _emailError = message;
    notifyListeners();
  }

  void setPasswordError(String? message) {
    _passwordError = message;
    notifyListeners();
  }

  void clearErrors() {
    _emailError = null;
    _passwordError = null;
    notifyListeners();
  }
}
