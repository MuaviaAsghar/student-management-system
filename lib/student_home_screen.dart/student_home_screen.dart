import 'package:flutter/material.dart';
import 'package:student_management_system/helpers/logout_logic.dart';

import 'student_attendance_mark_page.dart';
import 'student_attendance_view_page.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final LogoutLogic _logoutLogic = LogoutLogic();

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _logoutLogic.logout(context); // Proceed to logout
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 100,
          title: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.check), text: 'Mark Attendance'),
              Tab(icon: Icon(Icons.view_array), text: 'View Attendance'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            StudentAttendanceMarkPage(),
            StudentAttendanceViewPage(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _confirmLogout,
          label: const Text("Logout"),
        ),
      ),
    );
  }
}
