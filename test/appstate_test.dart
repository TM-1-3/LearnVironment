import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/app_state.dart';


void main() {
  group('ApplicationState', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser user;

    setUp(() {
      user = MockUser(uid: '123', email: 'email');
      mockFirebaseAuth = MockFirebaseAuth(mockUser: user);
    });

    test('Initial loggedIn state is false', () {
      final appState = ApplicationState(firebaseAuth: mockFirebaseAuth);
      expect(appState.loggedIn, isFalse);
    });

    test('loggedIn becomes true when user is signed in', () async {
      final appState = ApplicationState(firebaseAuth: mockFirebaseAuth);
      await mockFirebaseAuth.signInWithEmailAndPassword(email: 'email', password: 'pass');
      await Future.delayed(Duration(milliseconds: 100));

      expect(appState.loggedIn, isTrue);
    });

    test('loggedIn becomes false when user is signed out', () async {
      final appState = ApplicationState(firebaseAuth: mockFirebaseAuth);
      await mockFirebaseAuth.signInWithEmailAndPassword(email: 'email', password: 'pass');
      await mockFirebaseAuth.signOut();
      await Future.delayed(Duration(milliseconds: 100));

      expect(appState.loggedIn, isFalse);
    });

    test('updateLoggedInStatus works', () {
      final appState = ApplicationState(firebaseAuth: mockFirebaseAuth);

      appState.updateLoggedInStatus(true);
      expect(appState.loggedIn, isTrue);

      appState.updateLoggedInStatus(false);
      expect(appState.loggedIn, isFalse);
    });
  });
}