import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:mockito/mockito.dart';

// Mock FirebaseAuth
class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  Stream<User?> authStateChanges() {
    return super.noSuchMethod(
      Invocation.method(#authStateChanges, []),
      returnValue: Stream.value(
          null), // Return null for unauthenticated user by default
    );
  }
  @override
  User? get currentUser {
    return super.noSuchMethod(
      Invocation.method(#currentUser, []),
      returnValue: null,
    );
  }
  @override
  Future<void> signOut() async {
    return super.noSuchMethod(
      Invocation.method(#signOut, []),
      returnValue: Future.value(
          null), // Return null for unauthenticated user by default
    );
  }
}

// Mock User class, overriding necessary methods
class MockUser extends Mock implements User {
  @override
  Future<void> delete() async {
    super.noSuchMethod(
        Invocation.method(#delete, []),
        returnValue: Stream.value(null), );
  }
}

void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      authService = AuthService(firebaseAuth: mockFirebaseAuth);
    });

    test('initializes with loggedIn as false', () {
      expect(authService.loggedIn, false);
    });

    test('authStateChanges returns null for unauthenticated user', () async {
      when(mockFirebaseAuth.authStateChanges()).thenAnswer(
            (_) => Stream<User?>.value(null),
      );
      await authService.init();

      expect(authService.loggedIn, false);
    });

    test('authStateChanges returns a user when authenticated', () async {
      when(mockFirebaseAuth.authStateChanges()).thenAnswer(
            (_) => Stream<User?>.value(mockUser),
      );
      await authService.init();

      expect(authService.loggedIn, true);
    });

    test('should update loggedIn when authStateChanges emits a user', () async {
      final mockUser = MockUser();

      // Ensure we mock authStateChanges before calling init
      when(mockFirebaseAuth.authStateChanges()).thenAnswer(
            (_) => Stream.value(mockUser),
      );

      await authService.init();

      expect(authService.loggedIn, true);
    });

    test('should update loggedIn when authStateChanges emits null', () async {
      // Ensure we mock authStateChanges before calling init
      when(mockFirebaseAuth.authStateChanges()).thenAnswer(
            (_) => Stream.value(null),
      );

      await authService.init();

      expect(authService.loggedIn, false);
    });

    test('signOut should set loggedIn to false', () async {
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      await authService.signOut();

      expect(authService.loggedIn, false);
      verify(mockFirebaseAuth.signOut()).called(1);
    });

    test('deleteAccount should handle errors', () async {
      final mockUser = MockUser();

      // Mock currentUser to return a mock user
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // Mock the delete() method to throw an exception
      when(mockUser.delete()).thenThrow(Exception('Error deleting account'));

      try {
        await authService.deleteAccount();
        fail('Exception not thrown');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), contains('Error deleting account'));
      }
    });

    test('deleteAccount should call delete on current user', () async {
      final mockUser = MockUser();
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // Mock the delete method to simply return without any errors
      when(mockUser.delete()).thenAnswer((_) async {});

      await authService.deleteAccount();

      // Verify that delete was called once
      verify(mockUser.delete()).called(1);
    });
  });
}
