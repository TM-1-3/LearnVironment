import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/services/auth_service.dart';

class MockFirebaseAuthWithErrors extends MockFirebaseAuth {
  final bool shouldThrowEmailUsedError;
  final bool shouldThrowRegistrationOperationNotAllowedError;
  final bool shouldThrowRegistrationInvalidEmailError;

  final bool shouldThrowSignInError;
  final bool shouldThrowUserNotFoundError;
  final bool shouldThrowUserDisabledError;
  final bool shouldThrowSignInOperationNotAllowedError;
  final bool shouldThrowSignInInvalidEmailError;

  final bool shouldThrow;

  MockFirebaseAuthWithErrors({
    this.shouldThrowEmailUsedError = false,
    this.shouldThrowRegistrationOperationNotAllowedError = false,
    this.shouldThrowRegistrationInvalidEmailError = false,
    this.shouldThrowSignInError = false,
    this.shouldThrowUserNotFoundError = false,
    this.shouldThrowUserDisabledError = false,
    this.shouldThrowSignInOperationNotAllowedError = false,
    this.shouldThrowSignInInvalidEmailError = false,
    this.shouldThrow = false,
  });

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (shouldThrowEmailUsedError) {
      throw FirebaseAuthException(code: 'email-already-in-use');
    } else if (shouldThrowRegistrationOperationNotAllowedError) {
      throw FirebaseAuthException(code: 'operation-not-allowed');
    } else if (shouldThrowRegistrationInvalidEmailError) {
      throw FirebaseAuthException(code: 'invalid-email');
    } else if (shouldThrow) {
      throw FirebaseAuthException(code: 'any');
    }
    return super.createUserWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (shouldThrowSignInError) {
      throw FirebaseAuthException(code: 'wrong-password');
    } else if (shouldThrowUserNotFoundError) {
      throw FirebaseAuthException(code: 'user-not-found');
    } else if (shouldThrowUserDisabledError) {
      throw FirebaseAuthException(code: 'user-disabled');
    } else if (shouldThrowSignInOperationNotAllowedError) {
      throw FirebaseAuthException(code: 'operation-not-allowed');
    } else if (shouldThrowSignInInvalidEmailError) {
      throw FirebaseAuthException(code: 'invalid-email');
    } else if (shouldThrow) {
      throw FirebaseAuthException(code: 'any');
    }
    return super.signInWithEmailAndPassword(email: email, password: password);
  }
}

void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;

    setUp(() {
      mockUser = MockUser(
        uid: 'test',
        email: 'test@email.com',
        displayName: 'Test User',
      );
      mockFirebaseAuth = MockFirebaseAuth(mockUser: mockUser);
      authService = AuthService(firebaseAuth: mockFirebaseAuth);
    });

    test('initializes with loggedIn as false', () {
      expect(authService.loggedIn, false);
    });

    test('init should set loggedIn to true when a user is logged in', () async {
      mockFirebaseAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      authService = AuthService(firebaseAuth: mockFirebaseAuth);
      await authService.init();
      await Future.delayed(Duration.zero);
      expect(authService.loggedIn, true);
    });

    test('should update loggedIn when authStateChanges emits a user', () async {
      mockFirebaseAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      authService = AuthService(firebaseAuth: mockFirebaseAuth);
      await authService.init();
      expect(authService.loggedIn, true);
    });

    test('should update loggedIn when authStateChanges emits null', () async {
      await authService.init();
      expect(authService.loggedIn, false);
    });

    test('signOut should set loggedIn to false', () async {
      mockFirebaseAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      authService = AuthService(firebaseAuth: mockFirebaseAuth);
      await authService.signOut();
      expect(authService.loggedIn, false);
    });

    test('deleteAccount should handle errors', () async {
      mockFirebaseAuth = MockFirebaseAuth();
      authService = AuthService(firebaseAuth: mockFirebaseAuth);
      try {
        await authService.deleteAccount();
        fail('Exception not thrown');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), contains('Error deleting account'));
      }
    });

    test('getUid should return the user UID when a user is logged in', () async {
      mockFirebaseAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      authService = AuthService(firebaseAuth: mockFirebaseAuth);
      final uid = await authService.getUid();
      expect(uid, 'test');
    });

    test('getUid should throw an exception when no user is logged in', () async {
      try {
        await authService.getUid();
        fail('Exception not thrown');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), contains('No user logged in'));
      }
    });

    test('shows error when login fails with invalid credentials', () async {
      mockFirebaseAuth = MockFirebaseAuthWithErrors(shouldThrowSignInError: true);
      authService = AuthService(firebaseAuth: mockFirebaseAuth);

      try {
        await authService.signInWithEmailAndPassword(email: 'x', password: 'y');
        fail('Exception not thrown');
      } catch (e) {
        expect(e.toString(), contains('Wrong email/password combination.'));
      }
    });

    test('shows error when user not found', () async {
      mockFirebaseAuth = MockFirebaseAuthWithErrors(shouldThrowUserNotFoundError: true);
      authService = AuthService(firebaseAuth: mockFirebaseAuth);

      try {
        await authService.signInWithEmailAndPassword(email: 'x', password: 'y');
        fail('Exception not thrown');
      } catch (e) {
        expect(e.toString(), contains('No user found with this email.'));
      }
    });

    test('shows error when user is disabled', () async {
      mockFirebaseAuth = MockFirebaseAuthWithErrors(shouldThrowUserDisabledError: true);
      authService = AuthService(firebaseAuth: mockFirebaseAuth);

      try {
        await authService.signInWithEmailAndPassword(email: 'x', password: 'y');
        fail('Exception not thrown');
      } catch (e) {
        expect(e.toString(), contains('User disabled.'));
      }
    });

    test('shows error when too many requests', () async {
      mockFirebaseAuth = MockFirebaseAuthWithErrors(shouldThrowSignInOperationNotAllowedError: true);
      authService = AuthService(firebaseAuth: mockFirebaseAuth);

      try {
        await authService.signInWithEmailAndPassword(email: 'x', password: 'y');
        fail('Exception not thrown');
      } catch (e) {
        expect(e.toString(), contains('Too many requests.'));
      }
    });

    test('shows error when invalid email', () async {
      mockFirebaseAuth = MockFirebaseAuthWithErrors(shouldThrowSignInInvalidEmailError: true);
      authService = AuthService(firebaseAuth: mockFirebaseAuth);

      try {
        await authService.signInWithEmailAndPassword(email: 'x', password: 'y');
        fail('Exception not thrown');
      } catch (e) {
        expect(e.toString(), contains('Email address is invalid.'));
      }
    });

    test('handle unknown error', () async {
      mockFirebaseAuth = MockFirebaseAuthWithErrors(shouldThrow: true);
      authService = AuthService(firebaseAuth: mockFirebaseAuth);

      try {
        await authService.signInWithEmailAndPassword(email: 'x', password: 'y');
        fail('Exception not thrown');
      } catch (e) {
        expect(e.toString(), contains('Operation failed. Please try again.'));
      }
    });

    test('Error Email is in use', () async {
      mockFirebaseAuth = MockFirebaseAuthWithErrors(shouldThrowEmailUsedError: true);
      authService = AuthService(firebaseAuth: mockFirebaseAuth);

      try {
        await authService.registerUser(
            email: 'used@example.com', username: 'user', password: 'pass123');
        fail('Exception not thrown');
      } catch (e) {
        expect(e.toString(), contains('Email already used. Go to login page.'));
      }
    });

    test('Error Invalid Email', () async {
      mockFirebaseAuth = MockFirebaseAuthWithErrors(shouldThrowRegistrationInvalidEmailError: true);
      authService = AuthService(firebaseAuth: mockFirebaseAuth);

      try {
        await authService.registerUser(
            email: 'bademail', username: 'user', password: 'pass123');
        fail('Exception not thrown');
      } catch (e) {
        expect(e.toString(), contains('Email address is invalid.'));
      }
    });

    test('Unknown Error', () async {
      mockFirebaseAuth = MockFirebaseAuthWithErrors(shouldThrow: true);
      authService = AuthService(firebaseAuth: mockFirebaseAuth);

      try {
        await authService.registerUser(
            email: 'error@example.com', username: 'user', password: 'pass123');
        fail('Exception not thrown');
      } catch (e) {
        expect(e.toString(), contains('Operation failed. Please try again.'));
      }
    });

    test('Error Too many requests', () async {
      mockFirebaseAuth = MockFirebaseAuthWithErrors(shouldThrowRegistrationOperationNotAllowedError: true);
      authService = AuthService(firebaseAuth: mockFirebaseAuth);

      try {
        await authService.registerUser(
            email: 'rate@example.com', username: 'user', password: 'pass123');
        fail('Exception not thrown');
      } catch (e) {
        expect(e.toString(), contains('Too many requests.'));
      }
    });
  });
}
