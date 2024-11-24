import 'package:flutter/material.dart';
import 'package:student_management_system/helpers/logout_logic.dart';

import 'attendance_management_screen.dart';
import 'grading_system_screen.dart';
import 'leave_approvals_screen.dart';
import 'student_records_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final LogoutLogic _logoutLogic = LogoutLogic();

  int _currentIndex = 0;

  final List<Widget> _pages = [
    const StudentRecordsScreen(),
    const AttendanceManagementScreen(),
    const LeaveApprovalsScreen(),
    // const ReportGenerationScreen(),
    const GradingSystemScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Admin Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () => _logoutLogic.logout(context),
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue.shade800,
        selectedItemColor: Colors.amber, // Bright color for selected item
        unselectedItemColor:
            Colors.grey.shade300, // Light grey for unselected items
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: 'Leave Requests',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.insert_chart),
          //   label: 'Reports',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grade),
            label: 'Grades',
          ),
        ],
      ),
    );
  }
}
