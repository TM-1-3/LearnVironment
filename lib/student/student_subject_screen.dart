import 'package:flutter/material.dart';
import 'package:learnvironment/data/subject_data.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:provider/provider.dart';

class StudentSubjectScreen extends StatelessWidget {
  final SubjectData subjectData;

  const StudentSubjectScreen({
    super.key,
    required this.subjectData,
  });

  Future<Map<String, dynamic>?> getStudentData({
    required String studentId,
    required BuildContext context,
  }) async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final userData = await dataService.getUserData(userId: studentId);

      if (userData != null) {
        return {
          'name': userData.name,
          'email': userData.email,
        };
      } else {
        return null;
      }
    } catch (e) {
      print('[getStudentData] Error fetching student data: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> studentIds = subjectData.students;

    return Scaffold(
      appBar: AppBar(
        title: Text(subjectData.subjectName),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    subjectData.subjectLogo,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  subjectData.subjectName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Enrolled Students',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                studentIds.isNotEmpty
                    ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: studentIds.length,
                  itemBuilder: (context, index) {
                    final studentId = studentIds[index];

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: getStudentData(studentId: studentId, context: context),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const ListTile(
                            leading: Icon(Icons.person),
                            title: Text('Loading...'),
                            subtitle: Text('Fetching student info'),
                          );
                        } else if (snapshot.hasError || snapshot.data == null) {
                          return const ListTile(
                            leading: Icon(Icons.error),
                            title: Text('Unknown Student'),
                            subtitle: Text(''),
                          );
                        } else {
                          final studentData = snapshot.data!;
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(studentData['name'] ?? 'Unknown'),
                              subtitle: Text(studentData['email'] ?? ''),
                            ),
                          );
                        }
                      },
                    );
                  },
                )
                    : const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No students enrolled yet.',
                    style: TextStyle(fontSize: 16),
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
