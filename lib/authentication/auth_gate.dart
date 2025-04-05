import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learnvironment/developer/developer_home.dart';
import 'package:learnvironment/teacher/teacher_home.dart';
import 'package:provider/provider.dart';
import '../student/student_home.dart';
import 'auth_service.dart'; // AuthService
import 'fix_account.dart'; // FixAccountPage
import 'login_screen.dart'; // Import your custom LoginScreen

class AuthGate extends StatelessWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth fireauth;

  // Constructor to accept firestore dependency
  AuthGate({super.key, FirebaseFirestore? firestore, FirebaseAuth? fireauth})
      : firestore = firestore ?? FirebaseFirestore.instance,
        fireauth = fireauth ?? FirebaseAuth.instance;

  // Function to fetch userType from Firestore
  Future<String?> fetchUserType(String uid) async {
    try {
      final userDoc = await firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc['role']; // Fetch the "role" field
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching user role: $e");
      return null;
    }
  }

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

            // If the user is not authenticated, navigate to the LoginScreen
            if (!snapshot.hasData) {
              return LoginScreen(auth: fireauth); // Use your custom LoginScreen here
            }

            final user = snapshot.data!;
            return FutureBuilder<String?>(
              future: fetchUserType(user.uid),
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
                  return DeveloperHomePage();
                } else if (userType == 'student') {
                  return const StudentHomePage();
                } else if (userType == 'teacher') {
                  return const TeacherHomePage();
                } else {
                  return FixAccountPage(firestore: firestore, fireauth: fireauth);
                }
              },
            );
          },
        );
      },
    );
  }
}
