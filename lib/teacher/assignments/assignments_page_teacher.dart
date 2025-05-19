import 'package:flutter/material.dart';
import 'package:learnvironment/services/cache/user_cache_service.dart';
import 'package:learnvironment/teacher/assignments/assignment_page_teacher.dart';
import 'package:learnvironment/teacher/widgets/assignment_card_teacher.dart';
import 'package:learnvironment/services/firebase/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:provider/provider.dart';

class AssignmentsPageTeacher extends StatefulWidget {
  final String id;
  const AssignmentsPageTeacher({super.key, required this.id});

  @override
  AssignmentsPageTeacherState createState() => AssignmentsPageTeacherState();
}

class AssignmentsPageTeacherState extends State<AssignmentsPageTeacher> {
  String _searchQuery = "";
  List<Map<String, dynamic>> assignments = [];

  @override
  void initState() {
    super.initState();
    _fetchAssignments();
  }

  Future<void> _fetchAssignments() async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);

      final fetchedAssignments = await dataService.getAllAssignments(subjectId: widget.id);
      print('[AssignmentsPage] Fetched Assignments');
      setState(() {
        assignments = fetchedAssignments;
      });
    } catch (e) {
      print('[AssignmentsPage] Error fetching assignments: $e');
    }
  }

  List<Map<String, dynamic>> getFilteredAssignments() {
    return assignments.where((assignment) {
      final assignmentTitle = assignment['title'].toLowerCase();

      final matchesQuery = _searchQuery.isEmpty || assignmentTitle.contains(_searchQuery.toLowerCase());

      return matchesQuery;
    }).toList();
  }

  Future<void> _loadAssignment(String assignmentId) async {
    try {
      print('[Assignments Page] Loading Assignment');
      final dataService = Provider.of<DataService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);

      final assignmentData = await dataService.getAssignmentData(assignmentId: assignmentId);
      final userId = await authService.getUid();

      if (assignmentData != null && userId.isNotEmpty && mounted) {
        Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => AssignmentPageTeacher(assignmentData: assignmentData),
          ),
        );
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading assignment: $e')),
        );
      }
    }
  }

  Future<void> _refreshAssignments() async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final userCacheService = Provider.of<UserCacheService>(context, listen: false);
      await userCacheService.clearUserCache();

      final fetchedSubjects = await dataService.getAllAssignments(subjectId: widget.id);
      print('[AssignmentsPage] Refreshed assignments');
      setState((){
        assignments = fetchedSubjects;
      });
    } catch (e) {
      print('[AssignmentsPage] Error fetching assignments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/auth_gate');
          },
        ),
        title: TextField(
          key: Key('search'),
          onChanged: (query) {
            setState(() {
              _searchQuery = query.toLowerCase();
            });
          },
          decoration: const InputDecoration(
            hintText: 'Search assignments...',
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshAssignments,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double mainAxisExtent = 600.0;
                  if (constraints.maxWidth <= 600) {
                    mainAxisExtent = constraints.maxWidth;
                  } else if (constraints.maxWidth <= 1000) {
                    mainAxisExtent = 650;
                  } else if (constraints.maxWidth <= 2000) {
                    mainAxisExtent = 950;
                  } else {
                    mainAxisExtent = 1000;
                  }
                  final filteredAssignments = getFilteredAssignments();
                  return filteredAssignments.isNotEmpty
                      ? GridView.builder(
                    padding: const EdgeInsets.all(8),
                    physics: const AlwaysScrollableScrollPhysics(), // required for RefreshIndicator
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      mainAxisExtent: mainAxisExtent,
                    ),
                    itemCount: filteredAssignments.length,
                    itemBuilder: (context, index) {
                      final assignment = filteredAssignments[index];
                      return AssignmentCardTeacher(
                        assignmentTitle: assignment['title'],
                        assignmentId: assignment['assignmentId'],
                        loadAssignment: _loadAssignment,
                        gameId: assignment["gameId"],
                      );
                    },
                  )
                      : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 200),
                      Center(
                        child: Text(
                          'Create assignments by pressing the plus icon in the games page!',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
