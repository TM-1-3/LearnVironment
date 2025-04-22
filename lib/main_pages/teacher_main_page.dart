import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/data_service.dart';
import '../services/firestore_service.dart';

class TeacherMainPage extends StatefulWidget {
  const TeacherMainPage({super.key});

  @override
  TeacherMainPageState createState() => TeacherMainPageState();
}

class TeacherMainPageState extends State<TeacherMainPage> {
  List<Map<String, dynamic>> subjects = [];

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    try {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);

      final fetchedSubjects = await firestoreService.getAllSubjects();
      print('[TeacherMainPage] Fetched Subjects');
      setState(() {
        subjects = fetchedSubjects;
      });
    } catch (e) {
      print('[TeacherMainPage] Error fetching subjects: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}