import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaveApprovalsScreen extends StatefulWidget {
  const LeaveApprovalsScreen({super.key});

  @override
  State<LeaveApprovalsScreen> createState() => _LeaveApprovalsScreenState();
}

class _LeaveApprovalsScreenState extends State<LeaveApprovalsScreen> {
  // Stream to fetch leave requests
  Stream<List<Map<String, dynamic>>> getLeaveRequests() {
    return FirebaseFirestore.instance
        .collection('leave_requests')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {
                "id": doc.id,
                ...doc.data(),
              })
          .toList();
    });
  }

  // Method to approve leave request and update attendance
  Future<void> _approveLeaveRequest(String requestId, String email) async {
    try {
      // Update leave request status to "Approved"
      await FirebaseFirestore.instance
          .collection('leave_requests')
          .doc(requestId)
          .update({'status': 'Approved'});

      // Update the attendance record with "leave" status for today
      final studentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc('students')
          .collection(email)
          .get();
      DateTime now = DateTime.now();
      if (studentDoc.docs.isNotEmpty) {
        final studentId =
            studentDoc.docs.first.id; // Get the UID for this student
        await FirebaseFirestore.instance
            .collection('users')
            .doc('students')
            .collection(email)
            .doc(studentId)
            .collection('attendanceRecords')
            .doc(now.toIso8601String())
            .set({'date': Timestamp.fromDate(now), 'status': 'leave'});
      }
    } catch (e) {
      print("Error approving leave request: $e");
    }
  }

  // Method to reject leave request
  Future<void> _rejectLeaveRequestStatus(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('leave_requests')
          .doc(requestId)
          .update({'status': 'Rejected'});
    } catch (e) {
      print("Error rejecting leave request: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave Approvals"),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getLeaveRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading leave requests."));
          }

          final leaveRequests = snapshot.data ?? [];
          return ListView.builder(
            itemCount: leaveRequests.length,
            itemBuilder: (context, index) {
              final request = leaveRequests[index];
              final String status = request["status"];
              final String email = request['email'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: const Icon(Icons.request_page),
                  title: Text(request["studentName"]),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Reason: ${request["reason"]}"),
                      Text("Date: ${request["requestDate"]}"),
                      Text(
                        "Status: $status",
                        style: TextStyle(
                          color: status == "pending"
                              ? Colors.orange
                              : (status == "Approved"
                                  ? Colors.green
                                  : Colors.red),
                        ),
                      ),
                    ],
                  ),
                  trailing: status == "pending"
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.check, color: Colors.green),
                              onPressed: () =>
                                  _approveLeaveRequest(request["id"], email),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () =>
                                  _rejectLeaveRequestStatus(request["id"]),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
