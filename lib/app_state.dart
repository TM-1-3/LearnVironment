import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:learnvironment/firebase_options.dart';

class ApplicationState extends ChangeNotifier {
  final FirebaseAuth _auth;

  ApplicationState({FirebaseAuth? firebaseAuth}) : _auth = firebaseAuth ?? FirebaseAuth.instance {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseUIAuth.configureProviders([EmailAuthProvider()]);
    } catch (e) {
      print("Error initializing Firebase: $e");
      return;
    }

    _auth.authStateChanges().listen((user) {
      _loggedIn = user != null;
      notifyListeners();
    });
  }

  void updateLoggedInStatus(bool isLoggedIn) {
    _loggedIn = isLoggedIn;
    notifyListeners();
  }
}
