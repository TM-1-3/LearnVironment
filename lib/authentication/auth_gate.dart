import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:learnvironment/authentication/fix_account.dart';
import 'package:learnvironment/authentication/login_screen.dart';
import 'package:learnvironment/data/notification_storage.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/developer/developer_home.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/firestore_service.dart';
import 'package:learnvironment/student/student_home.dart';
import 'package:learnvironment/teacher/teacher_home.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Map<String, dynamic>> _initialize(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final dataService = Provider.of<DataService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final firebaseMessaging = Provider.of<FirebaseMessaging>(context, listen: false);

    final uid = await authService.getUid();

    if (!authService.fetchedNotifications) {
      //NotificationStorage.notificationMessages = await firestoreService.fetchNotifications(uid: uid);
      authService.fetchedNotifications = true;
    }

    final userData = await dataService.getUserData(userId: uid);

    if (userData != null && userData.classes.isNotEmpty) {
      for (var className in userData.classes) {
        String sanitizedClassName = className.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
        await firebaseMessaging.subscribeToTopic(sanitizedClassName);
        print('Subscribed to $sanitizedClassName');
      }
    }

    return {'userData': userData};
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    if (!authService.loggedIn) {
      return LoginScreen();
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _initialize(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)),
          );
        }

        final userData = snapshot.data?['userData'] as UserData?;

        if (userData == null) {
          return FixAccountPage();
        }

        switch (userData.role) {
          case 'developer':
            return DeveloperHomePage();
          case 'student':
            return StudentHomePage();
          case 'teacher':
            return TeacherHomePage();
          default:
            return FixAccountPage();
        }
      },
    );
  }
}
