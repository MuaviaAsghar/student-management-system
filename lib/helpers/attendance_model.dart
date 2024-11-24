import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final DateTime date;
  final String status;

  AttendanceRecord({
    required this.date,
    required this.status,
  });

  // Factory constructor to create an AttendanceRecord from Firestore data
  factory AttendanceRecord.fromMap(Map<String, dynamic> data) {
    return AttendanceRecord(
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] as String,
    );
  }

  // Method to convert AttendanceRecord to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'status': status,
    };
  }
}

class Attendance {
  final String studentId;
  final List<AttendanceRecord> records;

  Attendance({
    required this.studentId,
    required this.records,
  });

  // Factory constructor to create Attendance from Firestore data
  factory Attendance.fromDocument(DocumentSnapshot doc) {
    final List<dynamic> recordList = doc['attendanceRecords'] ?? [];
    List<AttendanceRecord> records = recordList
        .map((record) =>
            AttendanceRecord.fromMap(record as Map<String, dynamic>))
        .toList();

    return Attendance(
      studentId: doc.id,
      records: records,
    );
  }

  // Method to convert Attendance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'attendanceRecords': records.map((record) => record.toMap()).toList(),
    };
  }
}

// Firestore functions to add and retrieve attendance records

Future<void> addAttendanceRecord(
    String studentId, AttendanceRecord record) async {
  final docRef =
      FirebaseFirestore.instance.collection('attendance').doc(studentId);
  await docRef.update({
    'attendanceRecords': FieldValue.arrayUnion([record.toMap()])
  });
}

Future<Attendance?> getStudentAttendance(String studentId) async {
  final doc = await FirebaseFirestore.instance
      .collection('attendance')
      .doc(studentId)
      .get();
  if (doc.exists) {
    return Attendance.fromDocument(doc);
  }
  return null;
}
