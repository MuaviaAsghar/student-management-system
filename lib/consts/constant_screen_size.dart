import 'package:flutter/material.dart';

class ConstantScreenSize {
  final BuildContext context;

  ConstantScreenSize(this.context); // Pass context in the constructor

  double get screenHeight =>
      MediaQuery.sizeOf(context).height; // Get screen height
  double get screenWidth =>
      MediaQuery.sizeOf(context).width; // Get screen width
}
