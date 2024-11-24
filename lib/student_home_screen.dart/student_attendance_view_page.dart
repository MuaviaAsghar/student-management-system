import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class StudentAttendanceViewPage extends StatefulWidget {
  const StudentAttendanceViewPage({super.key});

  @override
  _StudentAttendanceViewPageState createState() =>
      _StudentAttendanceViewPageState();
}

class _StudentAttendanceViewPageState extends State<StudentAttendanceViewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Map<DateTime, Color> attendanceDates = {};
  int presentCount = 0;
  int absentCount = 0;
  int leaveCount = 0;

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    String currentUserEmail = _firebaseAuth.currentUser!.email!;
    String studentId = _firebaseAuth.currentUser!.uid;

    try {
      // Reference the attendance records subcollection
      QuerySnapshot attendanceSnapshots = await _firestore
          .collection('users')
          .doc('students')
          .collection(currentUserEmail)
          .doc(studentId)
          .collection('attendanceRecords')
          .get();

      Map<DateTime, Color> tempAttendanceDates = {};
      int tempPresentCount = 0;
      int tempAbsentCount = 0;
      int tempLeaveCount = 0;

      for (var doc in attendanceSnapshots.docs) {
        DateTime date = (doc['date'] as Timestamp).toDate();
        DateTime normalizedDate = DateTime(date.year, date.month, date.day);
        String status = doc['status'] as String;

        if (status == 'present') {
          tempAttendanceDates[normalizedDate] = Colors.green;
          tempPresentCount++;
        } else if (status == 'leave') {
          tempAttendanceDates[normalizedDate] = Colors.blue;
          tempLeaveCount++;
        } else if (status == 'absent') {
          tempAttendanceDates[normalizedDate] = Colors.red;
          tempAbsentCount++;
        }
      }

      setState(() {
        attendanceDates = tempAttendanceDates;
        presentCount = tempPresentCount;
        absentCount = tempAbsentCount;
        leaveCount = tempLeaveCount;
      });
    } catch (e) {
      print('Error fetching attendance data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("Attendance Calendar"),
      ),
      body: Column(
        children: [
          // Summary Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryCard("Present", presentCount, Colors.green),
                _buildSummaryCard("Absent", absentCount, Colors.red),
                _buildSummaryCard("Leave", leaveCount, Colors.blue),
              ],
            ),
          ),
          // Calendar
          Expanded(
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: DateTime.now(),
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              calendarStyle: const CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  DateTime date = DateTime(day.year, day.month, day.day);
                  Color? backgroundColor = attendanceDates[date];

                  bool isTodayWithoutRecord =
                      date == DateTime.now().toLocal() &&
                          backgroundColor == null;

                  return Container(
                    decoration: BoxDecoration(
                      color: isTodayWithoutRecord
                          ? Colors.transparent
                          : backgroundColor ?? Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isTodayWithoutRecord ||
                                    backgroundColor == null
                                ? Colors
                                    .black // Default color for unmarked days
                                : Colors.white,
                          ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Legend Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegend("Present", Colors.green),
                _buildLegend("Absent", Colors.red),
                _buildLegend("Leave", Colors.blue),
                _buildLegend(
                  "Today's Date",
                  const Color.fromARGB(100, 37, 150, 190),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method to build summary card for counts
  Widget _buildSummaryCard(String label, int count, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to build legend item
  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
