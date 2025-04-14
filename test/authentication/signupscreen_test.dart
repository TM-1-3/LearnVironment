import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/authentication/login_screen.dart';
import 'package:learnvironment/authentication/auth_gate.dart';
import 'package:learnvironment/authentication/signup_screen.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/firestore_service.dart';
import 'package:provider/provider.dart';

class MockLoginScreen extends LoginScreen {
  MockLoginScreen({super.key, super.authService});

  @override
  State<LoginScreen> createState() => _MockLoginScreenState();
}

class _MockLoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Mock Login Screen'),
      ),
    );
  }
}

class MockAuthService extends AuthService {
  final FirebaseAuth _firebaseAuth;

  MockAuthService({required FirebaseAuth firebaseAuth})
      : _firebaseAuth = firebaseAuth,
        super(firebaseAuth: firebaseAuth);

  Future<UserCredential?> signUp({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }

  User? get currentUser => _firebaseAuth.currentUser;
}

class MockAuthGate extends AuthGate {
  MockAuthGate({
    key,
  });

  @override
  Widget build(BuildContext context) {
    // You can provide a mock response for the build method if needed
    return const Scaffold(
      body: Center(
        child: Text('Mock AuthGate Screen'),
      ),
    );
  }
}

void main() {
  late MockUser mockUser;
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore mockFirestore;
  late Widget testWidget;
  late FirestoreService firestoreService;
  late MockAuthService authService;

  setUp(() {
    mockUser = MockUser(
      uid: 'abc123',
      email: 'test@example.com',
      displayName: 'testuser',
    );
    mockAuth = MockFirebaseAuth(mockUser: mockUser);
    mockFirestore = FakeFirebaseFirestore();
    firestoreService = FirestoreService(firestore: mockFirestore);
    authService = MockAuthService(firebaseAuth: mockAuth);

    testWidget = MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(
            create: (_) => authService,
          ),
        ],
        child: MaterialApp(
          routes: {
            '/auth_gate': (context) => MockAuthGate(),
            '/login': (context) => MockLoginScreen(authService: authService)
          },
          home: SignUpScreen(authService: authService, firestoreService: firestoreService),
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

      expect(find.byType(MockLoginScreen), findsOneWidget);
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
      expect(find.byType(MockAuthGate), findsOneWidget);
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