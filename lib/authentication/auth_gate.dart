import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learnvironment/authentication/fix_account.dart';
import 'package:learnvironment/authentication/login_screen.dart';
import 'package:learnvironment/developer/developer_home.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/firestore_service.dart';
import 'package:learnvironment/student/student_home.dart';
import 'package:learnvironment/teacher/teacher_home.dart';
import 'package:provider/provider.dart';


class AuthGate extends StatelessWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth fireauth;
  final FirestoreService firestoreService;

  // Constructor to accept firestore dependency
  AuthGate({super.key, FirebaseFirestore? firestore, FirebaseAuth? fireauth, FirestoreService? firestoreService})
      : firestore = firestore ?? FirebaseFirestore.instance,
        fireauth = fireauth ?? FirebaseAuth.instance,
        firestoreService = firestoreService ?? FirestoreService(firestore: firestore);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        return StreamBuilder<User?>(  // Listen to auth state changes
          stream: fireauth.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return LoginScreen();
            }

            final user = snapshot.data!;
            return FutureBuilder<String?>(
              future: firestoreService.fetchUserType(user.uid),
              builder: (context, userTypeSnapshot) {
                if (userTypeSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userTypeSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${userTypeSnapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final userType = userTypeSnapshot.data;
                if (userType == 'developer') {
                  return DeveloperHomePage(firestore: firestore, auth: fireauth);
                } else if (userType == 'student') {
                  return StudentHomePage(firestore: firestore, auth: fireauth);
                } else if (userType == 'teacher') {
                  return TeacherHomePage(firestore: firestore, auth: fireauth);
                } else {
                  return FixAccountPage(firestoreService: firestoreService);
                }
              },
            );
          },
        );
      },
    );
  }
}