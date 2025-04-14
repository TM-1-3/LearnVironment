import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learnvironment/authentication/fix_account.dart';
import 'package:learnvironment/authentication/login_screen.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/developer/developer_home.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/firestore_service.dart';
import 'package:learnvironment/services/user_cache_service.dart';
import 'package:learnvironment/student/student_home.dart';
import 'package:learnvironment/teacher/teacher_home.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        return StreamBuilder<User?>(
          stream: authService.authStateChanges, // Listen to auth state changes
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // If user is not logged in, show login screen
            if (!snapshot.hasData) {
              return LoginScreen();
            }

            final user = snapshot.data!;

            // Using FutureBuilder to fetch user data
            return FutureBuilder<UserData?>(
              future: _getUserData(context, user.uid),
              builder: (context, userDataSnapshot) {
                if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userDataSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${userDataSnapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final userData = userDataSnapshot.data;

                // If user data is not found or invalid role, navigate to fix account page
                if (userData == null || userData.role.isEmpty) {
                  return FixAccountPage();
                }

                // Navigate to appropriate home page based on role
                return _navigateToHomePage(userData.role);
              },
            );
          },
        );
      },
    );
  }

  // Fetch user data and return it
  Future<UserData?> _getUserData(BuildContext context, String userId) async {
    final userCacheService = Provider.of<UserCacheService>(context, listen: false);

    // Try to get cached user data
    UserData? userData = await userCacheService.getCachedUserData();

    // If cached data is unavailable, fetch it from Firestore
    if (userData == null) {
      if (context.mounted) {
        final firestoreService = Provider.of<FirestoreService>(
            context, listen: false);
        userData = await firestoreService.fetchUserData(userId);
        await userCacheService.cacheUserData(userData);
      }
    }

    return userData;
  }

  // Navigate to the correct page based on user role
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
}
