import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'student_detail_screen.dart';

class StudentRecordsScreen extends StatefulWidget {
  const StudentRecordsScreen({super.key});

  @override
  State<StudentRecordsScreen> createState() => _StudentRecordsScreenState();
}

class _StudentRecordsScreenState extends State<StudentRecordsScreen> {
  String _sortBy = 'name'; // Default sort by name

  // Fetch all students' data across the 'students' collection
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _getSortedStudents() async* {
    // Fetch the main students document, which contains an array of student emails
    final studentsIndexDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc('students_index')
        .get();

    final studentEmails =
        studentsIndexDoc.data()?['studentEmails'] as List<dynamic>? ?? [];

    List<QueryDocumentSnapshot<Map<String, dynamic>>> studentsList = [];

    for (var email in studentEmails) {
      final userDocs = await FirebaseFirestore.instance
          .collection('users')
          .doc('students')
          .collection(email)
          .get();

      print("User Docs for $email: ${userDocs.docs}"); // Debug

      studentsList.addAll(userDocs.docs);
    }

    print("Total Students Fetched: ${studentsList.length}"); // Debug
    yield studentsList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Student Records"),
        centerTitle: true,
        actions: [
          DropdownButton<String>(
            value: _sortBy,
            icon: const Icon(Icons.sort, color: Colors.white),
            onChanged: (String? newValue) {
              setState(() {
                _sortBy = newValue!;
              });
            },
            items:
                <String>['name'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child:
                    Text('Sort by ${value == 'name' ? 'Name' : 'Attendance'}'),
              );
            }).toList(),
          ),
        ],
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        stream: _getSortedStudents(),
        builder: (context,
            AsyncSnapshot<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
                snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Error loading student records: ${snapshot.error}');
            return const Center(child: Text("Failed to load student records."));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No student records found."));
          }

          final students = snapshot.data!;
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final studentData = students[index].data();
              final studentName = studentData['name'] ?? 'Unnamed Student';
              final profilePictureUrl = studentData['profilePictureUrl'] ?? '';
              final studentEmail = studentData['email'] ?? '';
              final studentId = students[index].id; // Get the document ID

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: profilePictureUrl.isNotEmpty
                      ? NetworkImage(profilePictureUrl)
                      : null,
                  child: profilePictureUrl.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(studentName),
                subtitle: Text('Email: $studentEmail'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentDetailScreen(
                        studentEmail: studentEmail,
                        studentId: studentId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
