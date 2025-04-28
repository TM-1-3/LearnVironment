import 'package:flutter/material.dart';
import 'package:learnvironment/data/assignment_data.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/teacher/assignments_page_teacher.dart';
import 'package:provider/provider.dart';

class AssignmentPageTeacher extends StatelessWidget {
  final AssignmentData assignmentData;

  const AssignmentPageTeacher({
    super.key,
    required this.assignmentData,
  });

  Future<void> _deleteAssigment(BuildContext context) async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      await dataService.deleteAssignment(assignmentId: assignmentId, uid: uid);
      if (context.mounted) {
        Navigator.of(context).pop(); // Go back after deletion
      }
    } catch (e) {
      print('[deleteSubject] Error deleting subject: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete subject.')),
        );
      }
    }
  }

  void confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: const Text('Are you sure you want to delete this subject? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Cancel
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog
              await _deleteAssigment(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(assignmentData.assignmentName),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  assignmentData.assignmentName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AssignmentsPageTeacher())) ;
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      child: Text("View Assignments", style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Enrolled Students',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () => confirmDelete(context),
                  icon: const Icon(Icons.delete),
                  key: Key("delete"),
                  label: const Text('Delete Assignment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
