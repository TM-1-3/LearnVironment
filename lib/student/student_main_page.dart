import 'package:flutter/material.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/student/student_subject_screen.dart';
import 'package:provider/provider.dart';

import '../services/data_service.dart';
import '../teacher/widgets/subject_card.dart';

class StudentMainPage extends StatefulWidget {
  const StudentMainPage({super.key});

  @override
  StudentMainPageState createState() => StudentMainPageState();
}

class StudentMainPageState extends State<StudentMainPage> {
  String _searchQuery = "";
  List<Map<String, dynamic>> subjects = [];

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);

      final fetchedSubjects = await dataService.getAllSubjects(uid: await authService.getUid());
      print('[StudentMainPage] Fetched Subjects');
      setState((){
        print(fetchedSubjects);
        subjects = fetchedSubjects;
      });
    } catch (e) {
      print('[StudentMainPage] Error fetching subjects: $e');
    }
  }

  List<Map<String, dynamic>> getFilteredSubjects() {
    return subjects.where((subjects) {
      final subjectName = subjects['subjectName'].toLowerCase();
      final matchesQuery =
          _searchQuery.isEmpty || subjectName.contains(_searchQuery.toLowerCase());
      return matchesQuery;
    }).toList();
  }

  Future<void> loadSubject(String subjectId) async {
    try {
      print('[Student Main Page] Loading Game');
      final dataService = Provider.of<DataService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);

      final subjectData = await dataService.getSubjectData(subjectId: subjectId);
      final userId = await authService.getUid();

      if (subjectData != null && userId.isNotEmpty && mounted) {
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => StudentSubjectScreen(subjectData: subjectData)),
        ).then((_) {
          _fetchSubjects();
        });
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading game: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSubjects = getFilteredSubjects();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          key: Key('search'),
          onChanged: (query) {
            setState(() {
              _searchQuery = query.toLowerCase();
            });
          },
          decoration: const InputDecoration(
            hintText: 'Search subjects...',
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double mainAxisExtent = 500.0;
                if (constraints.maxWidth <= 600) {
                  mainAxisExtent = constraints.maxWidth-150;
                } else if (constraints.maxWidth <= 1000) {
                  mainAxisExtent = 550;
                } else if (constraints.maxWidth <= 2000) {
                  mainAxisExtent = 950;
                } else {
                  mainAxisExtent = 1400;
                }

                return subjects.isNotEmpty
                    ? GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    mainAxisExtent: mainAxisExtent,
                  ),
                  itemCount: filteredSubjects.length,
                  itemBuilder: (context, index) {
                    final subject = filteredSubjects[index];
                    return SubjectCard(
                      imagePath: subject['imagePath'],
                      subjectName: subject['subjectName'],
                      subjectId: subject['subjectId'],
                      loadSubject: loadSubject,
                    );
                  },
                )
                    : const Center(
                  child: Text('No results found'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}