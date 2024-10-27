import 'package:flutter/material.dart';
import 'package:student_management_system/consts/constant_assets.dart';

import '../consts/constant_color.dart';
import '../consts/constant_screen_size.dart';
import '../helpers/admin_or_student_card.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    final screenSize = ConstantScreenSize(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: kBackGroundColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Centering the "Are you" text
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 25),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Are you a Student or Admin?",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Admin Card
                SizedBox(
                    height: screenSize.screenWidth * 0.4,
                    width: screenSize.screenWidth * 0.4,
                    child: const AdminOrStudentCard(
                      centerText: "Admin",
                      imgName: kAdminPNG,
                      color: Colors.blue,
                    )),

                // Divider between the cards
                Container(
                  height: screenSize.screenWidth *
                      0.4, // Divider height matching card height
                  width: 2, // Divider thickness
                  color: Colors.black,
                ),

                // Student Card
                SizedBox(
                    height: screenSize.screenWidth * 0.4,
                    width: screenSize.screenWidth * 0.4,
                    child: const AdminOrStudentCard(
                      centerText: "Student",
                      imgName: kStudentPNG,
                      color: Colors.green,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
