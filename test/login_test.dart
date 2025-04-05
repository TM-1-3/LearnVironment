import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/authentication/login_screen.dart';
import 'package:learnvironment/authentication/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockFirebaseAuthWithErrors extends MockFirebaseAuth {
  final bool shouldThrowSignInError;
  final bool shouldThrowUserNotFoundError;
  final bool shouldThrowUserDisabledError;
  final bool shouldThrowOperationNotAllowedError;
  final bool shouldThrowInvalidEmailError;
  final bool shouldThrow;

  MockFirebaseAuthWithErrors({
    this.shouldThrowSignInError = false,
    this.shouldThrowUserNotFoundError = false,
    this.shouldThrowUserDisabledError = false,
    this.shouldThrowOperationNotAllowedError = false,
    this.shouldThrowInvalidEmailError = false,
    this.shouldThrow = false
  });

  @override
  Future<UserCredential> signInWithEmailAndPassword({required String email, required String password}) async {
    if (shouldThrowSignInError) {
      throw FirebaseAuthException(code: 'wrong-password', message: 'Wrong email/password combination.');
    }else if (shouldThrowUserNotFoundError) {
      throw FirebaseAuthException(code: 'user-not-found', message: 'No user found with this email.');
    } else if (shouldThrowUserDisabledError) {
      throw FirebaseAuthException(code: 'user-disabled', message: 'User disabled.');
    } else if (shouldThrowOperationNotAllowedError) {
      throw FirebaseAuthException(code: 'operation-not-allowed', message: 'Too many requests to log into this account.');
    } else if (shouldThrowInvalidEmailError) {
      throw FirebaseAuthException(code: 'invalid-email', message: 'Email address is invalid.');
    } else if (shouldThrow) {
      throw FirebaseAuthException(code: 'any', message: 'Login failed. Please try again.');
    }
    return super.signInWithEmailAndPassword(email: email, password: password);
  }
}

void main() {
  late MockFirebaseAuth mockAuth;

  setUp(() {
    // Initialize MockFirebaseAuth with a mock user
    mockAuth = MockFirebaseAuth(
      mockUser: MockUser(
        email: 'test@example.com',
        displayName: 'Test User',
      ),
    );
  });

  group('LoginScreen Tests', () {
    late Widget testWidget;

    setUp(() {
      testWidget = MaterialApp(
        home: Scaffold(
          body: LoginScreen(auth: mockAuth),
        ),
        routes: {
          '/signup': (context) => SignUpScreen(),
        },
      );
    });

    testWidgets('renders the login screen correctly', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.text('Welcome to LearnVironment'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
      expect(find.text('Don’t have an account? Register here.'), findsOneWidget);
    });

    testWidgets('logs in successfully with valid credentials', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Enter valid credentials
      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');

      // Tap the login button
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Verify success message (e.g., SnackBar shows success)
      expect(find.text('Successfully logged in!'), findsOneWidget);
    });

    group('Error handling tests', () {
      testWidgets('shows error when login fails with invalid credentials', (WidgetTester tester) async {
        final mockAuthWithErrors = MockFirebaseAuthWithErrors(shouldThrowSignInError: true);

        final testWidget = MaterialApp(
          home: Scaffold(
            body: LoginScreen(auth: mockAuthWithErrors),
          ),
        );

        await tester.pumpWidget(testWidget);

        // Enter invalid credentials
        await tester.enterText(find.byType(TextField).at(0), 'wrong@example.com');
        await tester.enterText(find.byType(TextField).at(1), 'wrongpassword');

        // Tap the login button
        await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();

        // Verify error message in SnackBar
        expect(find.text('Wrong email/password combination.'), findsOneWidget);
      });

      testWidgets('shows error when user not found', (WidgetTester tester) async {
        final mockAuthWithErrors = MockFirebaseAuthWithErrors(shouldThrowUserNotFoundError: true);

        final testWidget = MaterialApp(
          home: Scaffold(
            body: LoginScreen(auth: mockAuthWithErrors),
          ),
        );

        await tester.pumpWidget(testWidget);

        // Enter invalid credentials
        await tester.enterText(find.byType(TextField).at(0), 'wrong@example.com');
        await tester.enterText(find.byType(TextField).at(1), 'wrongpassword');

        // Tap the login button
        await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();

        // Verify error message in SnackBar
        expect(find.text('No user found with this email.'), findsOneWidget);
      });

      testWidgets('shows error when user is disabled', (WidgetTester tester) async {
        final mockAuthWithErrors = MockFirebaseAuthWithErrors(shouldThrowUserDisabledError: true);

        final testWidget = MaterialApp(
          home: Scaffold(
            body: LoginScreen(auth: mockAuthWithErrors),
          ),
        );

        await tester.pumpWidget(testWidget);

        // Enter invalid credentials
        await tester.enterText(find.byType(TextField).at(0), 'wrong@example.com');
        await tester.enterText(find.byType(TextField).at(1), 'wrongpassword');

        // Tap the login button
        await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();

        // Verify error message in SnackBar
        expect(find.text('User disabled.'), findsOneWidget);
      });

      testWidgets('shows error when user is disabled', (WidgetTester tester) async {
        final mockAuthWithErrors = MockFirebaseAuthWithErrors(shouldThrowOperationNotAllowedError: true);

        final testWidget = MaterialApp(
          home: Scaffold(
            body: LoginScreen(auth: mockAuthWithErrors),
          ),
        );

        await tester.pumpWidget(testWidget);

        // Enter invalid credentials
        await tester.enterText(find.byType(TextField).at(0), 'wrong@example.com');
        await tester.enterText(find.byType(TextField).at(1), 'wrongpassword');

        // Tap the login button
        await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();

        // Verify error message in SnackBar
        expect(find.text('Too many requests to log into this account.'), findsOneWidget);
      });

      testWidgets('shows error for invalid email', (WidgetTester tester) async {
        final mockAuthWithErrors = MockFirebaseAuthWithErrors(shouldThrowInvalidEmailError: true);

        final testWidget = MaterialApp(
          home: Scaffold(
            body: LoginScreen(auth: mockAuthWithErrors),
          ),
        );

        await tester.pumpWidget(testWidget);

        // Enter invalid credentials
        await tester.enterText(find.byType(TextField).at(0), 'wrong@example.com');
        await tester.enterText(find.byType(TextField).at(1), 'wrongpassword');

        // Tap the login button
        await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();

        // Verify error message in SnackBar
        expect(find.text('Email address is invalid.'), findsOneWidget);
      });

      testWidgets('shows error when email or password is empty', (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);

        // Ensure fields are empty
        await tester.enterText(find.byType(TextField).at(0), ''); // Email field
        await tester.enterText(find.byType(TextField).at(1), ''); // Password field

        // Tap the login button
        await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();

        // Verify error message
        expect(find.text('Please fill in both fields.'), findsOneWidget);
      });

      testWidgets('handle unknown error', (WidgetTester tester) async {
        final mockAuthWithErrors = MockFirebaseAuthWithErrors(shouldThrow: true);

        final testWidget = MaterialApp(
          home: Scaffold(
            body: LoginScreen(auth: mockAuthWithErrors),
          ),
        );

        await tester.pumpWidget(testWidget);

        // Enter invalid credentials
        await tester.enterText(find.byType(TextField).at(0), 'wrong@example.com');
        await tester.enterText(find.byType(TextField).at(1), 'wrongpassword');

        // Tap the login button
        await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();

        // Verify error message in SnackBar
        expect(find.text('Login failed. Please try again.'), findsOneWidget);
      });
    });

    testWidgets('navigates to SignUpScreen when tapping registration link', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Tap the registration link
      await tester.ensureVisible(find.text('Don’t have an account? Register here.'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Don’t have an account? Register here.'));
      await tester.pumpAndSettle();

      // Verify navigation to SignUpScreen
      expect(find.byType(SignUpScreen), findsOneWidget);
    });
  });
}

