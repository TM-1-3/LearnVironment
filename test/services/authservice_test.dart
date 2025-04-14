import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/services/auth_service.dart';

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

      // Wait for the authStateChanges stream to emit
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
  });
}
