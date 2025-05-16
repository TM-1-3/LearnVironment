import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/authentication/login_screen.dart';
import 'package:learnvironment/authentication/reset_password_screen.dart';
import 'package:learnvironment/services/firebase/auth_service.dart';
import 'package:provider/provider.dart';

class MockLoginScreen extends LoginScreen {
  const MockLoginScreen({super.key});

  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Mock Login Screen'),
      ),
    );
  }
}

class MockAuthService extends AuthService {
  MockAuthService({MockFirebaseAuth? firebaseAuth})
      : super(firebaseAuth: firebaseAuth);

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (email == "throw") {
      throw Exception('Failed to send email');
    }
  }
}

void main() {
  late MockAuthService mockAuthService;
  late Widget testWidget;

  setUp(() {
    mockAuthService = MockAuthService(firebaseAuth: MockFirebaseAuth());
    testWidget = MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => mockAuthService)
      ],
      child: MaterialApp(
        home: ResetPasswordScreen(),
        routes: {
          '/login': (context) => MockLoginScreen(),
        },
      ),
    );
  });

  group('ResetPasswordScreen', () {
    testWidgets('renders UI elements correctly', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Reset Your Password'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows error when email is empty', (tester) async {
      await tester.pumpWidget(testWidget);

      await tester.tap(find.text('Reset Password'));
      await tester.pump();

      expect(find.text('Please enter your email address.'), findsOneWidget);
    });

    testWidgets('shows success snackbar on success', (tester) async {
      await tester.pumpWidget(testWidget);

      await tester.enterText(find.byType(TextField), 'test@example.com');
      await tester.tap(find.text('Reset Password'));
      await tester.pumpAndSettle();

      expect(find.text('Password reset link sent!'), findsOneWidget);
    });

    testWidgets('shows error snackbar on failure', (tester) async {
      await tester.pumpWidget(testWidget);

      await tester.enterText(find.byType(TextField), 'throw');
      await tester.tap(find.text('Reset Password'));
      await tester.pumpAndSettle();

      expect(find.text('Failed to send email'), findsOneWidget);
    });

    testWidgets('go to login page after email is sent', (tester) async {
        await tester.pumpWidget(testWidget);

        await tester.enterText(find.byType(TextField), 'test@example.com');
        await tester.tap(find.text('Reset Password'));
        await tester.pumpAndSettle();
        expect(find.text('Password reset link sent!'), findsOneWidget);

        await tester.pumpAndSettle();
        expect(find.byType(MockLoginScreen), findsOneWidget);
      });
  });
}
