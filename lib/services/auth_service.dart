import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  AuthService({FirebaseAuth? firebaseAuth}) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<void> init() async {
    _firebaseAuth.authStateChanges().listen((user) {
      _loggedIn = user != null;
      notifyListeners();
    });
  }

  //Method to get the user id
  Future<String> getUid() async {
    User? user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception("No user logged in");
    } else {
      return user.uid;
    }
  }

  // Sign out method
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _loggedIn = false;
    notifyListeners();
  }

  // Delete account method
  Future<void> deleteAccount() async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
      } else {
        throw Exception("Error deleting account");
      }
    } catch (e) {
      throw Exception("Error deleting account: $e");
    }
  }
}
