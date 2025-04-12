import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:learnvironment/firebase_options.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  Future<void> init() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // Handle Firebase initialization error
      print("Error initializing Firebase: $e");
      return;
    }

    // Set up Firebase UI providers
    FirebaseUIAuth.configureProviders([EmailAuthProvider()]);

    // Listen for authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _loggedIn = user != null;
      notifyListeners(); // Notify listeners of authentication state change
    });
  }

  // Method to manually update the logged-in status
  void updateLoggedInStatus(bool isLoggedIn) {
    _loggedIn = isLoggedIn;
    notifyListeners();
  }
}
