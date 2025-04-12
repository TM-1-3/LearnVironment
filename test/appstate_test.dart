import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/app_state.dart';
import 'dart:async';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApplicationState', () {
    late ApplicationState appState;
    late StreamController<User?> authStateController;
    late MockFirebaseAuth auth;

    setUp(() async {
      authStateController = StreamController<User?>.broadcast();
      auth = MockFirebaseAuth(signedIn: true,
        mockUser: MockUser(
          uid: 'testDeveloper',
          email: 'test@example.com',
          displayName: 'Test User',
        ),);

      appState = ApplicationState(firebaseAuth: auth);
      await Future.delayed(Duration(milliseconds: 100)); // Wait for async init
    });

    tearDown(() {
      authStateController.close();
    });

    test('initially not logged in', () {
      expect(appState.loggedIn, false);
    });

    test('updates loggedIn when user signs out', () async {
      authStateController.add(null);
      expect(appState.loggedIn, false);
    });
  });
}
