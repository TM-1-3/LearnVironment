import 'package:flutter/material.dart';
import 'package:learnvironment/data/subject_data.dart';
import 'package:learnvironment/services/firebase/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/teacher/assignments/assignments_page_teacher.dart';
import 'package:provider/provider.dart';

class TeacherSubjectScreen extends StatefulWidget {
  final SubjectData subjectData;

  const TeacherSubjectScreen({super.key, required this.subjectData});

  @override
  State<TeacherSubjectScreen> createState() => _TeacherSubjectScreenState();
}

class _TeacherSubjectScreenState extends State<TeacherSubjectScreen> {

  Future<Map<String, dynamic>?> _getStudentData({
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
          'username': userData.username,
        };
      } else {
        return null;
      }
    } catch (e) {
      print('[getStudentData] Error fetching student data: $e');
      return null;
    }
  }

  Future<void> _deleteSubject(BuildContext context) async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      await dataService.deleteSubject(subjectId: widget.subjectData.subjectId, uid: await authService.getUid());
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/auth_gate'); // Go back after deletion
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
      builder: (context) =>
          AlertDialog(
            title: const Text('Delete Subject'),
            content: const Text(
                'Are you sure you want to delete this subject? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // Cancel
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pushReplacementNamed('/auth_gate');
                  await _deleteSubject(context);
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
    final List<String> studentIds = widget.subjectData.students;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectData.subjectName),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 30.0, horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 180,
                    ),
                    child: widget.subjectData.subjectLogo.startsWith('assets/')
                        ? Image.asset(
                      widget.subjectData.subjectLogo,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                        : Image.network(
                      widget.subjectData.subjectLogo,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.subjectData.subjectName,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AssignmentsPageTeacher(id: widget.subjectData.subjectId))) ;
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
                const SizedBox(height: 10),
                studentIds.isNotEmpty
                    ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: studentIds.length,
                  itemBuilder: (context, index) {
                    final studentId = studentIds[index];

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _getStudentData(
                          studentId: studentId, context: context),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState
                            .waiting) {
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
                              title: Text(studentData['username'] ?? 'Unknown'),
                              subtitle: Text(studentData['email'] ?? ''),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                tooltip: 'Remove Student',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Remove Student'),
                                      content: const Text('Are you sure you want to remove this student from the class?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                          child: const Text('Remove'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    if (context.mounted) {
                                      final dataService = Provider.of<
                                          DataService>(context, listen: false);
                                      try {
                                        await dataService
                                            .removeStudentFromSubject(
                                          subjectId: widget.subjectData
                                              .subjectId,
                                          studentId: studentId,
                                        );

                                        setState(() {
                                          widget.subjectData.students.remove(
                                              studentId);
                                        });

                                        if (context.mounted) {
                                          ScaffoldMessenger
                                              .of(context)
                                              .showSnackBar(
                                            const SnackBar(content: Text(
                                                'Student removed successfully')),
                                          );
                                        }
                                      } catch (e) {
                                        print('Error removing student: $e');
                                        if (context.mounted) {
                                          ScaffoldMessenger
                                              .of(context)
                                              .showSnackBar(
                                            const SnackBar(content: Text(
                                                'Failed to remove student')),
                                          );
                                        }
                                      }
                                    }
                                  }
                                },
                              ),
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
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        final TextEditingController studentIdDialogController = TextEditingController();
                        return AlertDialog(
                          title: const Text('Add Student'),
                          content: TextField(
                            controller: studentIdDialogController,
                            decoration: const InputDecoration(
                              labelText: 'Enter Student Username',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final newStudentUserName = studentIdDialogController.text.trim();
                                if (newStudentUserName.isNotEmpty) {
                                  final dataService = Provider.of<DataService>(context, listen: false);
                                  final newStudentId = await dataService.getUserIdByUserName(newStudentUserName);
                                  if (newStudentId == null) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Student Not Found')),
                                      );
                                    }
                                    return;
                                  }
                                  final studentAlreadyInClass = await dataService.checkIfStudentAlreadyInClass(
                                    subjectId: widget.subjectData.subjectId,
                                    studentId: newStudentId,
                                  );
                                  if (studentAlreadyInClass) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Student is already in this subject')),
                                      );
                                    }
                                    return;
                                  }
                                  try {
                                    await dataService.addStudentToSubject(
                                      subjectId: widget.subjectData.subjectId,
                                      studentId: newStudentId,
                                    );

                                    setState(() {
                                      widget.subjectData.students.add(newStudentId);
                                    });

                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Student added successfully')),
                                      );
                                    }
                                  } catch (e) {
                                    print('Error adding student: $e');
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Failed to add student')),
                                      );
                                    }
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text('Add'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Student'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  key: Key("addStudent")
                ),

                const SizedBox(height: 20),

                // EXISTING - Delete Subject Button
                ElevatedButton.icon(
                  onPressed: () {
                    confirmDelete(context);
                  },
                  icon: const Icon(Icons.delete),
                  key: Key("delete"),
                  label: const Text('Delete Subject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 15),
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
