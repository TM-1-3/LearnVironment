import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/authentication/login_screen.dart';
import 'package:learnvironment/authentication/signup_screen.dart';
import 'package:mockito/mockito.dart';

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
