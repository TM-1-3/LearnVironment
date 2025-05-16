import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/authentication/login_screen.dart';
import 'package:learnvironment/authentication/auth_gate.dart';
import 'package:learnvironment/authentication/signup_screen.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:learnvironment/services/firebase/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

class MockDataService extends Mock implements DataService {
  MockDataService();

  @override
  Future<bool> checkIfUsernameAlreadyExists(String username) async {
    if (username=='testuser'){
      return true;
    }
    return false;
  }

  @override
  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String username,
    required String email,
    required String role,
    required String birthDate,
    required String img}) async {

  }
}

class MockAuthService extends AuthService {
  MockAuthService({MockFirebaseAuth? firebaseAuth})
      : super(firebaseAuth: firebaseAuth);

  @override
  Future<String?> registerUser({
    required String email,
    required String username,
    required String password,
  }) async {
    return "mockUserId123";
  }

  @override
  Stream<User?> get authStateChanges => Stream.value(MockUser());
}


class MockLoginScreen extends LoginScreen {
  MockLoginScreen({super.key});

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

class MockAuthGate extends AuthGate {
  MockAuthGate({key});

  @override
  Widget build(BuildContext context) {
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
  late Widget testWidget;
  late MockAuthService authService;
  late FakeFirebaseFirestore firestore;

  setUp(() {
    mockUser = MockUser(
      uid: 'abc123',
      email: 'test@example.com',
      displayName: 'testuser',
      isEmailVerified: false,
    );
    mockAuth = MockFirebaseAuth(mockUser: mockUser);
    authService = MockAuthService(firebaseAuth: mockAuth);
    firestore = FakeFirebaseFirestore();
    testWidget = MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(create: (_) => authService),
          Provider<DataService>(create: (_) => MockDataService())
        ],
        child: MaterialApp(
          routes: {
            '/auth_gate': (context) => MockAuthGate(),
            '/login': (context) => MockLoginScreen()
          },
          home: SignUpScreen(),
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

    testWidgets('shows error when username is already in use', (WidgetTester tester) async {
      await firestore.collection('users').doc('userInFirestore').set({
        'username':'testuser'
      });
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

      await tester.pump(); // starts the frame
      await tester.pump(const Duration(seconds: 2)); // gives time for async op
      await tester.pumpAndSettle(); // waits until animations and async are done

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Username already in use.'), findsOneWidget);
    });

    testWidgets('successful registration', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Test User');
      await tester.enterText(find.widgetWithText(TextField, 'Username'), 'testuser12');
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

      await tester.pump(); // starts the frame
      await tester.pump(const Duration(seconds: 2)); // gives time for async op
      await tester.pumpAndSettle(); // waits until animations and async are done

      expect(find.byType(SnackBar), findsOneWidget);
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