import 'package:flutter/material.dart';

import '../consts/constant_screen_size.dart';

class AdminOrStudentCard extends StatelessWidget {
  final String centerText;
  final Color color;
  final String imgName;

  const AdminOrStudentCard({
    super.key,
    required this.centerText,
    required this.color,
    required this.imgName,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = ConstantScreenSize(context);

    return InkWell(
      onTap: () {
        // Determine message based on card type
        final message = centerText == "Admin"
            ? "Enter the credentials provided by your team"
            : "Enter the credentials provided by your organization";

        // Navigate to LoginScreen with named route and arguments
        Navigator.pushNamed(
          context,
          '/loginscreen',
          arguments: {'message': message},
        );
      },
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the image
              Image.asset(
                imgName,
                height: screenSize.screenWidth * 0.1,
              ),
              const SizedBox(height: 10), // Space between image and text

              // Display the text
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  centerText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
