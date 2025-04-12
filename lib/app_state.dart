import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ApplicationState extends ChangeNotifier {
  final FirebaseAuth _auth;

  ApplicationState({FirebaseAuth? firebaseAuth}) : _auth = firebaseAuth ?? FirebaseAuth.instance {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  Future<void> init() async {
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
