import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learnvironment/developer/developer_home.dart';
import 'package:learnvironment/main_pages/games_page.dart';
import 'package:provider/provider.dart';
import '../student/student_home.dart';
import 'auth_service.dart'; // AuthService
import '../home_page.dart';
import 'fix_account.dart'; // FixAccountPage
import 'login_screen.dart'; // Import your custom LoginScreen

class AuthGate extends StatelessWidget {
  final FirebaseFirestore firestore;

  // Constructor to accept firestore dependency
  AuthGate({super.key, FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

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
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // If the user is not authenticated, navigate to the LoginScreen
            if (!snapshot.hasData) {
              return LoginScreen(); // Use your custom LoginScreen here
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
                  // Navigate to Developer Dashboard
                  return DeveloperHomePage(); // Replace with your developer screen
                } else if (userType == 'student') {
                  // Navigate to Student Home
                  return const StudentHomePage(); // Replace with your student screen
                } else {
                  // Navigate to Fix Account Page if role is missing or invalid
                  return const FixAccountPage();
                }
              },
            );
          },
        );
      },
    );
  }
}
