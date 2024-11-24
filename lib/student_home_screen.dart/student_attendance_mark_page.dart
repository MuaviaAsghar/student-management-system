import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentAttendanceMarkPage extends StatefulWidget {
  const StudentAttendanceMarkPage({super.key});

  @override
  State<StudentAttendanceMarkPage> createState() =>
      _StudentAttendanceMarkPageState();
}

class _StudentAttendanceMarkPageState extends State<StudentAttendanceMarkPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  List<Map<String, dynamic>> attendanceHistory = [];
  List<Map<String, dynamic>> leaveHistory = [];
  String? currentUserName;

  // Fetch current user's name from Firestore
  Future<void> fetchUserName() async {
    User? currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return;

    String? currentUserEmail = currentUser.email;
    String studentId = currentUser.uid;

    try {
      DocumentSnapshot studentDoc = await _firestore
          .collection('users')
          .doc('students')
          .collection(currentUserEmail!)
          .doc(studentId)
          .get();

      if (studentDoc.exists) {
        setState(() {
          currentUserName = studentDoc.get('name');
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user name: $e')),
      );
    }
  }

  // Method to mark attendance
  void _markPresence() async {
    User? currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in!')),
      );
      return;
    }

    String? currentUserEmail = currentUser.email;
    String studentId = currentUser.uid;
    DateTime now = DateTime.now();

    Map<String, dynamic> attendanceRecord = {
      'date': Timestamp.fromDate(now),
      'status': 'present',
    };

    try {
      DocumentReference studentDoc = _firestore
          .collection('users')
          .doc('students')
          .collection(currentUserEmail!)
          .doc(studentId)
          .collection('attendanceRecords')
          .doc(now.toIso8601String());

      await studentDoc.set(attendanceRecord);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marked as present!')),
      );
      _fetchAttendanceHistory(); // Refresh attendance history
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark attendance: $e')),
      );
    }
  }

  void _applyForLeave() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController reasonController = TextEditingController();

        return AlertDialog(
          title: const Text("Leave Application"),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: "Reason for Leave",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                User? currentUser = _firebaseAuth.currentUser;
                if (currentUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No user logged in!')),
                  );
                  return;
                }

                String? currentUserEmail = currentUser.email;
                DateTime now = DateTime.now();

                Map<String, dynamic> leaveRecord = {
                  'studentName': currentUserName,
                  'email': currentUserEmail,
                  'reason': reasonController.text,
                  'requestDate': Timestamp.fromDate(now),
                  'status': 'pending',
                };

                try {
                  DocumentReference leaveDoc = _firestore
                      .collection('leave_requests') // Change this line
                      .doc(now
                          .toIso8601String()); // Use the timestamp as the document ID

                  await leaveDoc.set(leaveRecord);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Leave application submitted!')),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to apply for leave: $e')),
                  );
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  // Method to fetch attendance history
  Future<void> _fetchAttendanceHistory() async {
    User? currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return;

    String? currentUserEmail = currentUser.email;
    String studentId = currentUser.uid;

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc('students')
          .collection(currentUserEmail!)
          .doc(studentId)
          .collection('attendanceRecords')
          .get();

      attendanceHistory = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      setState(() {}); // Refresh the UI with the new attendance history
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch attendance history: $e')),
      );
    }
  }

  // Method to fetch leave application history
  Future<void> _fetchLeaveHistory() async {
    User? currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return;

    String? currentUserEmail = currentUser.email;
    String studentId = currentUser.uid;

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc('students')
          .collection(currentUserEmail!)
          .doc(studentId)
          .collection('leaveApplications')
          .get();

      leaveHistory = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      setState(() {}); // Refresh the UI with the new leave history
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch leave history: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserName();
    _fetchAttendanceHistory(); // Fetch attendance history on page load
    _fetchLeaveHistory(); // Fetch leave history on page load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Attendance"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/updateDataScreen');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _markPresence,
                child: const Text("Mark Present"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _applyForLeave,
                child: const Text("Apply for Leave"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _showAttendanceHistory();
                },
                child: const Text("View Attendance History"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _showLeaveHistory();
                },
                child: const Text("View Leave History"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to display attendance history in a dialog
  void _showAttendanceHistory() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Attendance History"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: attendanceHistory.length,
              itemBuilder: (context, index) {
                final record = attendanceHistory[index];
                final date = (record['date'] as Timestamp).toDate();
                final status = record['status'];
                return ListTile(
                  title: Text('${date.toLocal()}'), // Display the date
                  subtitle: Text('Status: $status'), // Display the status
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // Method to display leave history in a dialog
  void _showLeaveHistory() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Leave Application History"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: leaveHistory.length,
              itemBuilder: (context, index) {
                final record = leaveHistory[index];
                final date = (record['date'] as Timestamp).toDate();
                final reason = record['reason'];
                final status = record['status'];
                return ListTile(
                  title: Text('${date.toLocal()}'), // Display the date
                  subtitle: Text(
                      'Reason: $reason\nStatus: $status'), // Display the reason and status
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
