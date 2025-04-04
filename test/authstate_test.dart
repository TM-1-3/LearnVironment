import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:learnvironment/authentication/auth_service.dart';

import 'mock_firebase.dart';

void main() {
  late AuthService authService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  setUp(() {
    // Initialize mock instances before each test
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    authService = AuthService(firebaseAuth: mockFirebaseAuth);  // Inject mock FirebaseAuth
  });

  // 1. Authentication Tests
  // 1. Authentication Tests
  test('authStateChanges returns null for unauthenticated user', () async {
    // Mock the behavior of authStateChanges() to return a stream that emits null (unauthenticated user)
    when(mockFirebaseAuth.authStateChanges()).thenAnswer(
          (_) => Stream<User?>.value(null), // This returns a stream that emits null
    );

    // Initialize the AuthService and listen for changes
    await authService.init();

    // Check that the loggedIn state is false because there's no authenticated user
    expect(authService.loggedIn, false);
  });

  test('authStateChanges returns a user when authenticated', () async {
    // Mock the behavior of authStateChanges() to return a stream that emits a mock user (authenticated user)
    when(mockFirebaseAuth.authStateChanges()).thenAnswer(
          (_) => Stream<User?>.value(mockUser), // This returns a stream that emits the mock user
    );

    // Initialize the AuthService and listen for changes
    await authService.init();

    // Check that the loggedIn state is true because we simulated an authenticated user
    expect(authService.loggedIn, true);
  });
}
