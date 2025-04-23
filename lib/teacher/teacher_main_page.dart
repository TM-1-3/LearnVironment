import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/data_service.dart';
import 'create_subject_page.dart';
import 'widgets/subject_card.dart';

class TeacherMainPage extends StatefulWidget {
  const TeacherMainPage({super.key});

  @override
  TeacherMainPageState createState() => TeacherMainPageState();
}

class TeacherMainPageState extends State<TeacherMainPage> {
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

      final fetchedSubjects = await dataService.getAllSubjects();
      print('[TeacherMainPage] Fetched Subjects');
      setState((){subjects = fetchedSubjects;});
    } catch (e) {
      print('[TeacherMainPage] Error fetching subjects: $e');
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

  /**
      Future<void> loadSubject(String subjectId) async {
      try {
      print('[Subject Page] Loading Subject Page');
      final dataService = Provider.of<DataService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);

      final subjectData = await dataService.getSubjectData(subjectId: subjectId);
      final userId = await authService.getUid();

      if (subjectData != null && userId.isNotEmpty && mounted) {
      Navigator.push(context,
      MaterialPageRoute(
      builder: (context) => SubjectScreen(subjectData: subjectData),
      ),
      );
      }
      } catch (e) {
      print(e);
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading subject page: $e')),
      );
      }
      }
      }
   **/

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
                double mainAxisExtent = 600.0;
                if (constraints.maxWidth <= 600) {
                  mainAxisExtent = constraints.maxWidth;
                } else if (constraints.maxWidth <= 1000) {
                  mainAxisExtent = 650;
                } else if (constraints.maxWidth <= 2000) {
                  mainAxisExtent = 1050;
                } else {
                  mainAxisExtent = 1500;
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
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = filteredSubjects[index];
                    return SubjectCard(
                      imagePath: subject['imagePath'],
                      subjectName: subject['subjectName'],
                      subjectId: subject['subjectId'],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateSubjectPage()),
          ).then((_) {
            // Refresh subjects when coming back from create page
            _fetchSubjects();
          });
        },
        child: Image.asset('assets/trash1.png', width: 50, height: 50),
        backgroundColor: Colors.grey,
      ),

    );
  }
}