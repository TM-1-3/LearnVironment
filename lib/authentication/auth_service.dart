import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;

  bool _loggedIn = false;

  bool get loggedIn => _loggedIn;

  // Constructor to accept firebaseAuth as a parameter
  AuthService({FirebaseAuth? firebaseAuth}) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Initialize AuthService
  Future<void> init() async {
    _firebaseAuth.authStateChanges().listen((user) {
      _loggedIn = user != null;
      notifyListeners();
    });
  }

  // Sign out method
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _loggedIn = false;
    notifyListeners();
  }
}
