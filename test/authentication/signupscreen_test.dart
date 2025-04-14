import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/authentication/login_screen.dart';
import 'package:learnvironment/authentication/auth_gate.dart';
import 'package:learnvironment/authentication/signup_screen.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:provider/provider.dart';

class MockFirebaseAuthWithErrors extends MockFirebaseAuth {
  final bool shouldThrowEmailUsedError;
  final bool shouldThrowOperationNotAllowedError;
  final bool shouldThrowInvalidEmailError;
  final bool shouldThrow;

  MockFirebaseAuthWithErrors({
    this.shouldThrowEmailUsedError = false,
    this.shouldThrowOperationNotAllowedError = false,
    this.shouldThrowInvalidEmailError = false,
    this.shouldThrow = false
  });

  @override
  Future<UserCredential> createUserWithEmailAndPassword({required String email, required String password}) async {
    if (shouldThrowEmailUsedError) {
      throw FirebaseAuthException(code: 'email-already-in-use', message: 'Email already used. Use login page.');
    } else if (shouldThrowOperationNotAllowedError) {
      throw FirebaseAuthException(code: 'operation-not-allowed', message: 'Too many requests to register into this account.');
    } else if (shouldThrowInvalidEmailError) {
      throw FirebaseAuthException(code: 'invalid-email', message: 'Email address is invalid.');
    } else if (shouldThrow) {
      throw FirebaseAuthException(code: 'any', message: 'Registration failed. Please try again.');
    }
    return super.createUserWithEmailAndPassword(email: email, password: password);
  }
}

void main() {
  late MockUser mockUser;
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore mockFirestore;
  late Widget testWidget;

  setUp(() {
    mockUser = MockUser(
      uid: 'abc123',
      email: 'test@example.com',
      displayName: 'testuser',
    );
    mockAuth = MockFirebaseAuth(mockUser: mockUser);
    mockFirestore = FakeFirebaseFirestore();

    testWidget = MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(firebaseAuth: mockAuth),
          ),
        ],
        child: MaterialApp(
          routes: {
            '/auth_gate': (context) => AuthGate(fireauth: mockAuth, firestore: mockFirestore),
            '/login': (context) => LoginScreen(auth: mockAuth)
          },
          home: SignUpScreen(firestore: mockFirestore, auth: mockAuth),
        )
    );
  });

  group('Widget Tests', () {
    testWidgets('Page is rendered correctly', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // AppBar title
      expect(find.text('Sign Up'), findsOneWidget);

      // Icon image
      expect(find.byType(Image), findsOneWidget);

      // All text fields
      expect(find.widgetWithText(TextField, 'Name'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Birthdate'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Username'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Confirm Password'), findsOneWidget);

      // Dropdown hint
      expect(find.text('Select Account Type'), findsOneWidget);

      // Register button
      expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);

      // Login redirect text
      expect(find.text('Already have an account? Log in here.'), findsOneWidget);
    });

    testWidgets('Navigation to login page works', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.ensureVisible(find.text('Already have an account? Log in here.'));
      await tester.tap(find.text('Already have an account? Log in here.'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Birthdate selector works', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Find the birthdate TextField
      final dateField = find.byKey(Key("birthDate"));
      await tester.ensureVisible(dateField);
      await tester.pumpAndSettle();
      await tester.tap(dateField);
      await tester.pumpAndSettle();
      expect(find.byType(CalendarDatePicker), findsOneWidget);

      //Select Year
      await tester.ensureVisible(find.text('January 2000'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('January 2000'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('1993'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1993'));
      await tester.pumpAndSettle();

      //Select Date
      await tester.ensureVisible(find.text('20'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();

      //Enter Date
      await tester.ensureVisible(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, '1993-01-20'), findsOneWidget);
    });

    testWidgets('User Type selection works', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      //Select developer
      await tester.ensureVisible(find.byType(DropdownButton<String>));
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      expect(find.text('developer'), findsOneWidget);
      expect(find.text('student'), findsOneWidget);
      expect(find.text('teacher'), findsOneWidget);
      await tester.tap(find.text('developer').last);
      await tester.pumpAndSettle();
      expect(find.text('developer'), findsWidgets);

      //Select Student
      await tester.ensureVisible(find.byType(DropdownButton<String>));
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('student').last);
      await tester.pumpAndSettle();
      expect(find.text('student'), findsWidgets);

      //Select Teacher
      await tester.ensureVisible(find.byType(DropdownButton<String>));
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('teacher').last);
      await tester.pumpAndSettle();
      expect(find.text('teacher'), findsWidgets);
    });

    testWidgets('Error Empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      await tester.ensureVisible(find.text('Register'));
      await tester.tap(find.text('Register'));
      await tester.pump();

      expect(find.text('Please fill in all fields.'), findsOneWidget);
    });

    testWidgets('Error Email is in use', (WidgetTester tester) async {
      final mockAuthWithErrors = MockFirebaseAuthWithErrors(shouldThrowEmailUsedError: true);

      final testWidget = MaterialApp(
            home: SignUpScreen(firestore: mockFirestore, auth: mockAuthWithErrors),
      );

      await tester.pumpWidget(testWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Test User');
      await tester.enterText(find.widgetWithText(TextField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'up202307719@up.pt');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextField, 'Confirm Password'), 'password123');

      //Select Student
      await tester.ensureVisible(find.byType(DropdownButton<String>));
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('student').last);
      await tester.pumpAndSettle();

      //Select Birthdate
      final dateField = find.byKey(Key("birthDate"));
      await tester.ensureVisible(dateField);
      await tester.pumpAndSettle();
      await tester.tap(dateField);
      await tester.pumpAndSettle();
      expect(find.byType(CalendarDatePicker), findsOneWidget);
      await tester.ensureVisible(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Register'));
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Email already used. Use login page.'), findsOneWidget);
    });

    testWidgets('Error Invalid Email', (WidgetTester tester) async {
      final mockAuthWithErrors = MockFirebaseAuthWithErrors(shouldThrowInvalidEmailError: true);

      final testWidget = MaterialApp(
        home: SignUpScreen(firestore: mockFirestore, auth: mockAuthWithErrors),
      );

      await tester.pumpWidget(testWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Test User');
      await tester.enterText(find.widgetWithText(TextField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'up202307719@up.pt');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextField, 'Confirm Password'), 'password123');

      //Select Student
      await tester.ensureVisible(find.byType(DropdownButton<String>));
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('student').last);
      await tester.pumpAndSettle();

      //Select Birthdate
      final dateField = find.byKey(Key("birthDate"));
      await tester.ensureVisible(dateField);
      await tester.pumpAndSettle();
      await tester.tap(dateField);
      await tester.pumpAndSettle();
      expect(find.byType(CalendarDatePicker), findsOneWidget);
      await tester.ensureVisible(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Register'));
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Email address is invalid.'), findsOneWidget);
    });

    testWidgets('Unknown Error', (WidgetTester tester) async {
      final mockAuthWithErrors = MockFirebaseAuthWithErrors(shouldThrow: true);

      final testWidget = MaterialApp(
        home: SignUpScreen(firestore: mockFirestore, auth: mockAuthWithErrors),
      );

      await tester.pumpWidget(testWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Test User');
      await tester.enterText(find.widgetWithText(TextField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'up202307719@up.pt');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextField, 'Confirm Password'), 'password123');

      //Select Student
      await tester.ensureVisible(find.byType(DropdownButton<String>));
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('student').last);
      await tester.pumpAndSettle();

      //Select Birthdate
      final dateField = find.byKey(Key("birthDate"));
      await tester.ensureVisible(dateField);
      await tester.pumpAndSettle();
      await tester.tap(dateField);
      await tester.pumpAndSettle();
      expect(find.byType(CalendarDatePicker), findsOneWidget);
      await tester.ensureVisible(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Register'));
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Registration failed. Please try again.'), findsOneWidget);
    });

    testWidgets('Error Too many requests', (WidgetTester tester) async {
      final mockAuthWithErrors = MockFirebaseAuthWithErrors(shouldThrowOperationNotAllowedError: true);

      final testWidget = MaterialApp(
        home: SignUpScreen(firestore: mockFirestore, auth: mockAuthWithErrors),
      );

      await tester.pumpWidget(testWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Test User');
      await tester.enterText(find.widgetWithText(TextField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'up202307719@up.pt');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextField, 'Confirm Password'), 'password123');

      //Select Student
      await tester.ensureVisible(find.byType(DropdownButton<String>));
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('student').last);
      await tester.pumpAndSettle();

      //Select Birthdate
      final dateField = find.byKey(Key("birthDate"));
      await tester.ensureVisible(dateField);
      await tester.pumpAndSettle();
      await tester.tap(dateField);
      await tester.pumpAndSettle();
      expect(find.byType(CalendarDatePicker), findsOneWidget);
      await tester.ensureVisible(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Register'));
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Too many requests to register into this account.'), findsOneWidget);
    });

    testWidgets('successful registration', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Test User');
      await tester.enterText(find.widgetWithText(TextField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextField, 'Confirm Password'), 'password123');

      //Select Student
      await tester.ensureVisible(find.byType(DropdownButton<String>));
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('student').last);
      await tester.pumpAndSettle();

      //Select Birthdate
      final dateField = find.byKey(Key("birthDate"));
      await tester.ensureVisible(dateField);
      await tester.pumpAndSettle();
      await tester.tap(dateField);
      await tester.pumpAndSettle();
      expect(find.byType(CalendarDatePicker), findsOneWidget);
      await tester.ensureVisible(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Register'));
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Account created successfully! Please verify your email.'), findsOneWidget);
    });
  });

  group('Edge Case Tests', () {
    testWidgets('birthdate must be set', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Test User');
      await tester.enterText(find.widgetWithText(TextField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextField, 'Confirm Password'), 'password123');

      //Select Student
      await tester.ensureVisible(find.byType(DropdownButton<String>));
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('student').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Register'));
      await tester.tap(find.text('Register'));
      await tester.pump();

      expect(find.text('Please fill in all fields.'), findsOneWidget);
    });

    testWidgets('name must be set', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextField, 'Confirm Password'), 'password123');

      //Select Student
      await tester.ensureVisible(find.byType(DropdownButton<String>));
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('student').last);
      await tester.pumpAndSettle();

      //Select Birthdate
      final dateField = find.byKey(Key("birthDate"));
      await tester.ensureVisible(dateField);
      await tester.pumpAndSettle();
      await tester.tap(dateField);
      await tester.pumpAndSettle();
      expect(find.byType(CalendarDatePicker), findsOneWidget);
      await tester.ensureVisible(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Register'));
      await tester.tap(find.text('Register'));
      await tester.pump();

      expect(find.text('Please fill in all fields.'), findsOneWidget);
    });

    testWidgets('usertype must be set', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Test User');
      await tester.enterText(find.widgetWithText(TextField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextField, 'Confirm Password'), 'password123');

      //Select Birthdate
      final dateField = find.byKey(Key("birthDate"));
      await tester.ensureVisible(dateField);
      await tester.pumpAndSettle();
      await tester.tap(dateField);
      await tester.pumpAndSettle();
      expect(find.byType(CalendarDatePicker), findsOneWidget);
      await tester.ensureVisible(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Register'));
      await tester.tap(find.text('Register'));
      await tester.pump();

      expect(find.text('Please fill in all fields.'), findsOneWidget);
    });
  });
}