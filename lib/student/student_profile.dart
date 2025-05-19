import 'package:flutter/material.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:provider/provider.dart';

class StudentProfilePage extends StatefulWidget {
  final String studentId;

  const StudentProfilePage({super.key, required this.studentId});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  UserData? studentData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final data = await dataService.getUserData(userId: widget.studentId);
      if (data != null) {
        setState(() {
          studentData = data;
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Student not found";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Error loading student data";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isLoading
                ? const CircularProgressIndicator()
                : error != null
                ? Text(error!, style: const TextStyle(color: Colors.red))
                : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                studentData!.img != "assets/placeholder.png"
                    ? CircleAvatar(
                  backgroundImage: NetworkImage(studentData!.img),
                  radius: 100,
                )
                    : CircleAvatar(
                  backgroundImage: AssetImage(studentData!.img),
                  radius: 100,
                ),
                const SizedBox(height: 20),
                Text(
                  studentData!.name,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '@${studentData!.username}',
                  style: const TextStyle(fontSize: 26, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  studentData!.email,
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
