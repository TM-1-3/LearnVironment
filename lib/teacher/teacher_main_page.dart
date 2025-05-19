import 'package:flutter/material.dart';
import 'package:learnvironment/services/firebase/auth_service.dart';
import 'package:learnvironment/services/cache/user_cache_service.dart';
import 'package:learnvironment/teacher/classes/teacher_subject_screen.dart';
import 'package:provider/provider.dart';

import '../services/data_service.dart';
import 'classes/create_subject_page.dart';
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
      final authService = Provider.of<AuthService>(context, listen: false);

      final fetchedSubjects = await dataService.getAllSubjects(uid: await authService.getUid());
      print('[TeacherMainPage] Fetched Subjects');
      setState((){
        subjects = fetchedSubjects;
      });
    } catch (e) {
      print('[TeacherMainPage] Error fetching subjects: $e');
    }
  }

  Future<void> _refreshSubjects() async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final userCacheService = Provider.of<UserCacheService>(context, listen: false);
      await userCacheService.clearUserCache();

      final fetchedSubjects = await dataService.getAllSubjects(uid: await authService.getUid());
      print('[TeacherMainPage] Refreshed Subjects');
      setState((){
        subjects = fetchedSubjects;
      });
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

  Future<void> loadSubject(String subjectId) async {
    try {
      print('[Teacher Main Page] Loading Game');
      final dataService = Provider.of<DataService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);

      final subjectData = await dataService.getSubjectData(subjectId: subjectId, forceRefresh: false);
      final userId = await authService.getUid();

      if (subjectData != null && userId.isNotEmpty && mounted) {
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => TeacherSubjectScreen(subjectData: subjectData)),
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

    final screenWidth = MediaQuery.of(context).size.width;
    double mainAxisExtent = 500.0;
    if (screenWidth <= 600) {
      mainAxisExtent = screenWidth - 150;
    } else if (screenWidth <= 1000) {
      mainAxisExtent = 550;
    } else if (screenWidth <= 2000) {
      mainAxisExtent = 950;
    } else {
      mainAxisExtent = 1400;
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
            child: RefreshIndicator(
              onRefresh: _refreshSubjects,
              child: ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                    subjects.isNotEmpty
                        ? GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
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
                        : SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: const Center(child: Text('No results found')),
                    )
                ]
              ),
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
        child: Icon(Icons.add),
      ),
    );
  }
}