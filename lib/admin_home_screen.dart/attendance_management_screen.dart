import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceManagementScreen extends StatefulWidget {
  const AttendanceManagementScreen({super.key});

  @override
  State<AttendanceManagementScreen> createState() =>
      _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState extends State<AttendanceManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  DateTime? _startDate;
  DateTime? _endDate;
  final List<Map<String, dynamic>> _filteredAttendanceRecords = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _generateReport() async {
    if (_startDate == null || _endDate == null) return;

    _filteredAttendanceRecords.clear();
    final Map<String, Map<String, int>> attendanceSummary = {};

    // Fetch studentEmails list
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc('students_index')
        .get();

    final studentEmails = List<String>.from(snapshot['studentEmails'] ?? []);

    for (String email in studentEmails) {
      final studentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc('students')
          .collection(email)
          .get();

      for (var studentDoc in studentSnapshot.docs) {
        final studentId = studentDoc.id;
        final studentName = studentDoc['name'] ?? 'Unnamed Student';

        // Fetch attendance records within date range
        final attendanceSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc('students')
            .collection(email)
            .doc(studentId)
            .collection('attendanceRecords')
            .where('date', isGreaterThanOrEqualTo: _startDate)
            .where('date', isLessThanOrEqualTo: _endDate)
            .get();

        print(
            "Fetching attendance for $studentName: ${attendanceSnapshot.docs.length} records found");

        // Initialize or update attendance summary for this student
        if (!attendanceSummary.containsKey(studentName)) {
          attendanceSummary[studentName] = {
            'present': 0,
            'absent': 0,
            'leave': 0
          };
        }

        for (var record in attendanceSnapshot.docs) {
          final status = record['status'];
          print("Status for $studentName: $status"); // Debug line
          if (status == 'present' || status == 'absent' || status == 'leave') {
            attendanceSummary[studentName]![status] =
                (attendanceSummary[studentName]![status] ?? 0) + 1;
          }
        }
      }
    }

    _filteredAttendanceRecords.clear();
    attendanceSummary.forEach((studentName, counts) {
      _filteredAttendanceRecords.add({
        'studentName': studentName,
        'present': counts['present'],
        'absent': counts['absent'],
        'leave': counts['leave'],
      });
    });

    setState(() {}); // Refresh UI to display report results
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Attendance Management"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Records'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _attendanceRecordsTab(),
          _reportsTab(),
        ],
      ),
    );
  }

  // Attendance Records Tab
  Widget _attendanceRecordsTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc('students_index')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("Error loading attendance records."));
        }

        final studentEmails =
            List<String>.from(snapshot.data!['studentEmails'] ?? []);
        return ListView.builder(
          itemCount: studentEmails.length,
          itemBuilder: (context, index) {
            final email = studentEmails[index];
            return ListTile(
              title: Text(email),
              subtitle: const Text("View attendance records"),
            );
          },
        );
      },
    );
  }

// Modify _reportsTab to display the summarized attendance counts
  Widget _reportsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            "Generate Attendance Report",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(
                    text: _startDate == null
                        ? ''
                        : DateFormat('dd/MM/yyyy').format(_startDate!),
                  ),
                  decoration: const InputDecoration(
                    labelText: "Start Date",
                    border: OutlineInputBorder(),
                  ),
                  onTap: () => _selectDate(context, true),
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: TextEditingController(
                    text: _endDate == null
                        ? ''
                        : DateFormat('dd/MM/yyyy').format(_endDate!),
                  ),
                  decoration: const InputDecoration(
                    labelText: "End Date",
                    border: OutlineInputBorder(),
                  ),
                  onTap: () => _selectDate(context, false),
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _generateReport,
            child: const Text("Generate Report"),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _filteredAttendanceRecords.isEmpty
                ? const Text("No records found.")
                : ListView.builder(
                    itemCount: _filteredAttendanceRecords.length,
                    itemBuilder: (context, index) {
                      final record = _filteredAttendanceRecords[index];
                      return ListTile(
                        title: Text(record['studentName']),
                        subtitle: Text(
                          "Present: ${record['present']}, "
                          "Absent: ${record['absent']}, "
                          "Leave: ${record['leave']}",
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
