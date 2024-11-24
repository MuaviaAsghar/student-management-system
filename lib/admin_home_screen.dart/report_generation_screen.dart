// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class ReportGenerationScreen extends StatefulWidget {
//   const ReportGenerationScreen({super.key});

//   @override
//   State<ReportGenerationScreen> createState() => _ReportGenerationScreenState();
// }

// class _ReportGenerationScreenState extends State<ReportGenerationScreen> {
//   DateTime? _startDate;
//   DateTime? _endDate;

//   // Function to pick a date range
//   Future<void> _selectDateRange(BuildContext context) async {
//     final DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2023),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         _startDate = picked.start;
//         _endDate = picked.end;
//       });
//     }
//   }

//   // Function to generate report (placeholder logic)
//   void _generateReport() {
//     if (_startDate == null || _endDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select a date range")),
//       );
//       return;
//     }

//     // Placeholder for Firebase query or data generation logic
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Generating report...")),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Generate Report"),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextButton(
//               onPressed: () => _selectDateRange(context),
//               child: Text(
//                 _startDate != null && _endDate != null
//                     ? "Selected Range: ${DateFormat('yyyy-MM-dd').format(_startDate!)} - ${DateFormat('yyyy-MM-dd').format(_endDate!)}"
//                     : "Select Date Range",
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _generateReport,
//               child: const Text("Generate Full Attendance Report"),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: _generateReport,
//               child: const Text("Generate Individual Student Report"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
