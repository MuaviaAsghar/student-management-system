import 'package:flutter/material.dart';

class GradingSystemScreen extends StatefulWidget {
  const GradingSystemScreen({super.key});

  @override
  State<GradingSystemScreen> createState() => _GradingSystemScreenState();
}

class _GradingSystemScreenState extends State<GradingSystemScreen> {
  final List<Map<String, dynamic>> _gradingCriteria = [
    {"grade": "A", "minDays": 26},
    {"grade": "B", "minDays": 20},
    {"grade": "C", "minDays": 15},
    {"grade": "D", "minDays": 10},
    {"grade": "F", "minDays": 0},
  ];

  void _updateMinDays(int index, int newMinDays) {
    setState(() {
      _gradingCriteria[index]["minDays"] = newMinDays;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("Grading System"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Set Minimum Attendance Days for Grades",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _gradingCriteria.length,
                itemBuilder: (context, index) {
                  final grade = _gradingCriteria[index]["grade"];
                  final minDays = _gradingCriteria[index]["minDays"];

                  return ListTile(
                    title: Text("Grade $grade"),
                    subtitle: Text("Minimum Days: $minDays"),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final int? newMinDays = await _showEditDialog(minDays);
                        if (newMinDays != null) {
                          _updateMinDays(index, newMinDays);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Grading criteria saved!")),
                );
                // Here, you could add logic to save the grading criteria to Firebase or another database.
              },
              child: const Text("Save Criteria"),
            ),
          ],
        ),
      ),
    );
  }

  Future<int?> _showEditDialog(int currentMinDays) async {
    int? newMinDays = currentMinDays;
    return await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Minimum Days"),
          content: TextFormField(
            initialValue: currentMinDays.toString(),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              newMinDays = int.tryParse(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, currentMinDays),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, newMinDays),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
