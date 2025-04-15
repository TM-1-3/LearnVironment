import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get loggedIn => _currentUser != null;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<void> init() async {
    _firebaseAuth.authStateChanges().listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  // Method to get the user id
  Future<String> getUid() async {
    User? user = _currentUser;
    if (user == null) {
      throw Exception("No user logged in");
    } else {
      return user.uid;
    }
  }

  Future<void> updateUsername(String newUsername) async {
    try {
      _firebaseAuth.currentUser?.updateDisplayName(newUsername);
    } catch (e) {
      throw Exception("Error updating username: $e");
    }
  }

  Future<void> updateEmail(String newEmail, String password) async {
    try {
      User? user = _firebaseAuth.currentUser;
      final AuthCredential credential = EmailAuthProvider.credential(
        email: user?.email ?? '',
        password: password,
      );

      await user?.reauthenticateWithCredential(credential);

      // Only update the email if the new email is different from the current one
      if (newEmail != user?.email) {
        await user?.verifyBeforeUpdateEmail(newEmail); // Update email in Firebase
        print("Email updated successfully.");

        // Send verification email only if the email is not already verified
        if (!user!.emailVerified) {
          await user.sendEmailVerification();
        }
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  // Sign out method
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // Delete account method
  Future<void> deleteAccount() async {
    try {
      User? user = _currentUser;
      if (user != null) {
        await user.delete();
        _currentUser = null;
      } else {
        throw Exception("Error deleting account");
      }
    } catch (e) {
      throw Exception("Error deleting account: $e");
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = _firebaseAuth.currentUser;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      throw Exception("An unexpected error occurred.");
    }
  }

  // Register User
  Future<String?> registerUser({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(username);
      await userCredential.user?.sendEmailVerification();

      _currentUser = _firebaseAuth.currentUser;
      notifyListeners();

      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      throw Exception("An unexpected error occurred.");
    }
  }

  // Helper method to handle FirebaseAuth exceptions
  String _getErrorMessage(String code) {
    switch (code) {
      case "ERROR_EMAIL_ALREADY_IN_USE":
      case "account-exists-with-different-credential":
      case "email-already-in-use":
        return "Email already used. Go to login page.";
      case "ERROR_WRONG_PASSWORD":
      case "wrong-password":
        return "Wrong email/password combination.";
      case "ERROR_USER_NOT_FOUND":
      case "user-not-found":
        return "No user found with this email.";
      case "ERROR_USER_DISABLED":
      case "user-disabled":
        return "User disabled.";
      case "ERROR_TOO_MANY_REQUESTS":
      case "ERROR_OPERATION_NOT_ALLOWED":
      case "operation-not-allowed":
        return "Too many requests.";
      case "ERROR_INVALID_EMAIL":
      case "invalid-email":
        return "Email address is invalid.";
      default:
        return "Operation failed. Please try again.";
    }
  }
}
