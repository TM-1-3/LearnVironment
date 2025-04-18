import 'package:flutter/material.dart';
import 'package:learnvironment/authentication/fix_account.dart';
import 'package:learnvironment/authentication/login_screen.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/developer/developer_home.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/student/student_home.dart';
import 'package:learnvironment/teacher/teacher_home.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  Future<UserData?> _loadUserData(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final dataService = Provider.of<DataService>(context, listen: false);
    return await dataService.getUserData(userId: await authService.getUid());
  }

  Widget _navigateToHomePage(String role) {
    switch (role) {
      case 'developer':
        return DeveloperHomePage();
      case 'student':
        return StudentHomePage();
      case 'teacher':
        return TeacherHomePage();
      default:
        return FixAccountPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.loggedIn) {
      return LoginScreen();
    }

    return FutureBuilder<UserData?>(
      future: _loadUserData(context),
      builder: (context, userDataSnapshot) {
        if (userDataSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userDataSnapshot.hasError) {
          print('Error: ${userDataSnapshot.error}');
          return Center(
            child: Text('Error: ${userDataSnapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final userData = userDataSnapshot.data;

        if (userData == null || userData.role.isEmpty) {
          return FixAccountPage();
        }
        return _navigateToHomePage(userData.role);
      },
    );
  }
}
