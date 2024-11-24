import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentDetailScreen extends StatelessWidget {
  final String studentEmail;
  final String studentId;

  const StudentDetailScreen({
    super.key,
    required this.studentEmail,
    required this.studentId,
  });

  Stream<QuerySnapshot> _getAttendanceRecords() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc('students')
        .collection(studentEmail)
        .doc(studentId)
        .collection('attendanceRecords')
        .orderBy('date', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Student Details"),
      ),
      body: StreamBuilder(
        stream: _getAttendanceRecords(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
                child: Text("Failed to load attendance records."));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("No attendance records available."));
          }

          final attendanceRecords = snapshot.data!.docs;
          return ListView.builder(
            itemCount: attendanceRecords.length,
            itemBuilder: (context, index) {
              final record =
                  attendanceRecords[index].data() as Map<String, dynamic>;
              final date = (record['date'] as Timestamp).toDate();
              final status = record['status'] ?? 'Unknown';

              return ListTile(
                title: Text("Date: ${date.toLocal().toString().split(' ')[0]}"),
                subtitle: Text("Status: $status"),
                leading: CircleAvatar(
                  backgroundColor: status == 'present'
                      ? Colors.green
                      : status == 'absent'
                          ? Colors.red
                          : Colors.blue,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
