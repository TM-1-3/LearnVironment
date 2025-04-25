import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:mockito/mockito.dart';

class MockUserCredential extends Mock implements UserCredential {}

class MockUserUnit extends Mock implements User {
  String _email;
  String _displayName;
  bool _emailVerified;

  MockUserUnit({
    required String email,
    required String displayName,
    bool? emailVerified,
  })  : _email = email,
        _displayName = displayName,
        _emailVerified = emailVerified ?? true;

  @override
  String? get email => _email;

  @override
  String? get displayName => _displayName;

  @override
  bool get emailVerified => _emailVerified;

  @override
  Future<void> verifyBeforeUpdateEmail(String newEmail, [ActionCodeSettings? actionCodeSettings]) async {
    if (newEmail == "throw") {
      throw Exception();
    }
    print('Mock: Verifying email before update: $newEmail');
    _email = newEmail;
    print("Updated Email");
    return Future.value();
  }

  @override
  Future<void> updateDisplayName(String? displayName) async {
    if (displayName == "Throw") {
      throw Exception();
    }
    _displayName = displayName ?? '';
    print("Updated DisplayName");
    return Future.value();
  }

  @override
  Future<UserCredential> reauthenticateWithCredential(AuthCredential credential) async {
    return MockUserCredential();
  }
}

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

  final MockUserUnit user;

  @override
  User get currentUser => user;

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
    MockUserUnit? user,
  }): user = user ?? MockUserUnit(email: "email@gmail.com", displayName: "Me");

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

  @override
  Future<void> sendPasswordResetEmail({required String email, ActionCodeSettings? actionCodeSettings}) async {
    if (shouldThrow) {
      throw FirebaseAuthException(code: 'any');
    } else {
      //Do nothing
    }
  }
}

void main() {
  group('AuthService Initialization', () {
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
  });

  group('AuthService Sign Out', () {
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

    test('signOut should set loggedIn to false', () async {
      mockFirebaseAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      authService = AuthService(firebaseAuth: mockFirebaseAuth);
      await authService.signOut();
      expect(authService.loggedIn, false);
    });
  });

  group('AuthService Delete Account', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      authService = AuthService(firebaseAuth: mockFirebaseAuth);
    });

    test('deleteAccount should handle errors', () async {
      mockFirebaseAuth = MockFirebaseAuth();
      authService = AuthService(firebaseAuth: mockFirebaseAuth);
      try {
        await authService.deleteAccount(password: 'password');
        fail('Exception not thrown');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), contains('Error deleting account'));
      }
    });
  });

  group('AuthService Get UID', () {
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
  });

  group('AuthService Sign In Errors', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      authService = AuthService(firebaseAuth: mockFirebaseAuth);
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
  });

  group('AuthService Registration Errors', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      authService = AuthService(firebaseAuth: mockFirebaseAuth);
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

  group('AuthService Update Username', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUserUnit mockUser;

    setUp(() {
      mockUser = MockUserUnit(email: 'test@email.com', displayName: 'Test User',);
      mockFirebaseAuth = MockFirebaseAuthWithErrors(user: mockUser);
      authService = AuthService(firebaseAuth: mockFirebaseAuth);
    });

    test('updateUsername should successfully update the username', () async {
      await authService.updateUsername(newUsername: 'New Username');
      expect(mockUser.displayName, 'New Username');
    });

    test('updateUsername should throw an exception if update fails', () async {
      mockFirebaseAuth = MockFirebaseAuthWithErrors(shouldThrow: true);
      authService = AuthService(firebaseAuth: mockFirebaseAuth);
      try {
        await authService.updateUsername(newUsername: 'Throw');
        fail('Exception not thrown');
      } catch (e) {
        expect(e.toString(), contains('Error updating username:'));
      }
    });
  });

  group('AuthService Update Email', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUserUnit mockUser;

    setUp(() {
      mockUser = MockUserUnit(email: 'test@email.com', displayName: 'Test User',);
      mockFirebaseAuth = MockFirebaseAuthWithErrors(user: mockUser);
      authService = AuthService(firebaseAuth: mockFirebaseAuth);
    });

    test('updateEmail should successfully update the email', () async {
      await authService.updateEmail(newEmail: 'newemail@example.com', password: 'password');
      expect(mockUser.email, 'newemail@example.com');
    });

    test('updateEmail should throw an exception if update fails', () async {
      mockFirebaseAuth = MockFirebaseAuthWithErrors(shouldThrow: true);
      authService = AuthService(firebaseAuth: mockFirebaseAuth);
      try {
        await authService.updateEmail(newEmail: 'throw', password: 'wrongpassword');
        fail('Exception not thrown');
      } catch (e) {
        expect(e.toString(), contains('Error updating email:'));
      }
    });
  });

  group('AuthService Send Password Reset Email', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      authService = AuthService(firebaseAuth: mockFirebaseAuth);
    });

    test('sendPasswordResetEmail should send a reset email', () async {
      await authService.sendPasswordResetEmail('test@example.com');
      // Add check for the expected outcome, if possible.
    });

    test('sendPasswordResetEmail should throw an exception if failed', () async {
      mockFirebaseAuth = MockFirebaseAuthWithErrors(shouldThrow: true);
      authService = AuthService(firebaseAuth: mockFirebaseAuth);
      try {
        await authService.sendPasswordResetEmail('test@example.com');
        fail('Exception not thrown');
      } catch (e) {
        expect(e.toString(), contains('Failed to send password reset email:'));
      }
    });
  });

  group('AuthService Register User', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      authService = AuthService(firebaseAuth: mockFirebaseAuth);
    });

    test('registerUser should register a new user and return UID', () async {
      final uid = await authService.registerUser(
        email: 'newuser@example.com',
        username: 'New User',
        password: 'password123',
      );
      expect(uid, isNotNull);
    });
  });
}
