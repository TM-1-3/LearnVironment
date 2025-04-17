import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/authentication/auth_gate.dart';
import 'package:learnvironment/authentication/fix_account.dart';
import 'package:learnvironment/authentication/login_screen.dart';
import 'package:learnvironment/authentication/signup_screen.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockDataService extends Mock implements DataService {
  @override
  Future<UserData?> getUserData({required String userId}) {
    // Return different roles based on userId for different tests
    if (userId == 'testDeveloper') {
      return Future.value(UserData(role: 'developer', id: 'testDeveloper', username: 'Test User', email: 'test@example.com', name: 'Dev', birthdate: DateTime(2000, 1, 1, 0, 0, 0, 0, 0), gamesPlayed: []));
    } else if (userId == 'testStudent') {
      return Future.value(UserData(role: 'student', id: '', username: '', email: '', name: '', birthdate: DateTime(2000, 1, 1, 0, 0, 0, 0, 0), gamesPlayed: []));
    } else if (userId == 'testTeacher') {
      return Future.value(UserData(role: 'teacher', id: '', username: '', email: '', name: '', birthdate: DateTime(2000, 1, 1, 0, 0, 0, 0, 0), gamesPlayed: []));
    } else {
      return Future.value(UserData(role: '', id: '', username: '', name: '', email: '', birthdate: DateTime(2000, 1, 1, 0, 0, 0, 0, 0), gamesPlayed: []));
    }
  }
}

class MockAuthService extends AuthService {
  MockAuthService({MockFirebaseAuth? firebaseAuth})
      : super(firebaseAuth: firebaseAuth);

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {

  }

  @override
  Stream<User?> get authStateChanges => Stream.value(MockUser());
}

void main() {
  late MockFirebaseAuth mockAuth;

  setUp(() {
    mockAuth = MockFirebaseAuth(
      mockUser: MockUser(
        email: 'test@example.com',
        displayName: 'Test User',
      ),
    );
  });

  group('LoginScreen Tests', () {
    late Widget testWidget;

    setUp(() async {
      final authService = AuthService(firebaseAuth: mockAuth);
      await authService.init();

      testWidget = MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(create: (_) => authService),
          Provider<DataService>(create: (context) => MockDataService()),
        ],
        child: MaterialApp(
          home: LoginScreen(),
          routes: {
            '/auth_gate': (context) => AuthGate(),
            '/fix_account': (context) => FixAccountPage(),
            '/login': (context) => LoginScreen(),
            '/signup': (context) => SignUpScreen(),
          },
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

