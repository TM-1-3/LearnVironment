import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  late bool loggedIn = false;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<void> init() async {
    _firebaseAuth.authStateChanges().listen((user) {
      if (user != null){
        loggedIn = true;
      }
      notifyListeners();
    });
  }

  // Method to get the user id
  Future<String> getUid() async {
    User? user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception("No user logged in");
    } else {
      return user.uid;
    }
  }

  Future<void> updateUsername({required String newUsername}) async {
    try {
      User? user = _firebaseAuth.currentUser;
      await user?.updateDisplayName(newUsername);
    } catch (e) {
      print(e);
      throw Exception("Error updating username: $e");
    }
  }

  Future<void> updateEmail({required String newEmail, required String password}) async {
    try {
      User? user = _firebaseAuth.currentUser;
      final AuthCredential credential = EmailAuthProvider.credential(
        email: user?.email ?? '',
        password: password,
      );

      await user?.reauthenticateWithCredential(credential);

      if (newEmail != user?.email) {
        await user?.verifyBeforeUpdateEmail(newEmail);
        print("Email updated successfully.");

        // Send verification email only if the email is not already verified
        if (!user!.emailVerified) {
          await user.sendEmailVerification();
        }
      }
    } catch (e) {
      throw Exception("Error updating email: $e");
    }
  }

  // Sign out method
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    loggedIn = false;
    notifyListeners();
  }

  // Delete account method
  Future<void> deleteAccount({required String password}) async {
    try {

      User? user = _firebaseAuth.currentUser;
      final AuthCredential credential = EmailAuthProvider.credential(
        email: user?.email ?? '',
        password: password,
      );

      await user?.reauthenticateWithCredential(credential);
      if (user != null) {
        await user.delete();
        loggedIn = false;
      } else {
        throw Exception("Error deleting account");
      }
    } catch (e) {
      throw Exception("Error deleting account: $e");
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword({required String email, required String password,}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      loggedIn = true;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(code: e.code));
    } catch (e) {
      throw Exception("An unexpected error occurred.");
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to send password reset email: ${e.message}');
    }
  }

  // Register User
  Future<String?> registerUser({required String email, required String username, required String password}) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(username);
      await userCredential.user?.sendEmailVerification();

      loggedIn = true;
      notifyListeners();
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(code: e.code));
    } catch (e) {
      throw Exception("An unexpected error occurred.");
    }
  }

  // Helper method to handle FirebaseAuth exceptions
  String _getErrorMessage({required String code}) {
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
