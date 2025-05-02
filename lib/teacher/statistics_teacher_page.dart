import 'package:flutter/material.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsTeacherPage extends StatefulWidget {

  StatisticsTeacherPage({
    super.key,
  });

  @override
  StatisticsTeacherPageState createState() => StatisticsTeacherPageState();
}

class StatisticsTeacherPageState extends State<StatisticsTeacherPage> {
  bool _isSaved = true;
  late TextEditingController titleController;
  late String _selectedClass;
  late List<String> _classes = [];

  @override
  void initState() {
    super.initState();
    _selectedClass = '';
    _loadClasses();

  }
  Future<void> _loadClasses() async {
    try {
      DataService dataService = Provider.of<DataService>(context, listen: false);
      AuthService authService = Provider.of<AuthService>(context, listen: false);
      UserData? userData = await dataService.getUserData(userId: await authService.getUid());
      if (userData == null) {
        _showErrorDialog("No user is logged in.", "Error");
        return;
      }
      setState(() {
        _classes = userData.classes;
      });
    } catch (e) {
      print("Failed to load Classes");
      rethrow;
    }
  }
  void _showErrorDialog(String message, String ctx) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(ctx),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: null,
            decoration: const InputDecoration(labelText: 'Class'),
            items: _classes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedClass = newValue;
                  _isSaved = false;
                });
              }
            },
          ),

        ]
    );
  }
}