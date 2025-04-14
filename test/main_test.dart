import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/authentication/fix_account.dart';
import 'package:learnvironment/authentication/login_screen.dart';
import 'package:learnvironment/authentication/signup_screen.dart';
import 'package:learnvironment/main.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:learnvironment/authentication/auth_gate.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() async {
  group('App Initialization Tests', () {
    testWidgets('AuthService provider is initialized', (tester) async {
      MockFirebaseAuth mockAuth = MockFirebaseAuth();
      FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();
      await tester.pumpWidget(
        MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthService>(
                  create: (_) => AuthService(firebaseAuth: mockAuth)),
            ],
            child: App(firestore: fakeFirestore, fireauth: mockAuth)),
      );

      // Verify that AuthService is created and provided
      expect(
        Provider.of<AuthService>(
            tester.element(find.byType(App)), listen: false),
        isNotNull,
      );
    });
  });

  group('Widget Rendering Tests', () {
    testWidgets('AuthGate widget renders correctly', (tester) async {
      MockFirebaseAuth mockAuth = MockFirebaseAuth();
      FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();
      await tester.pumpWidget(
          MultiProvider(
              providers: [
                ChangeNotifierProvider<AuthService>(
                  create: (_) => AuthService(firebaseAuth: mockAuth),
                ),
              ],
              child: MaterialApp(
                home: AuthGate(firestore: fakeFirestore, fireauth: mockAuth),
              ),
      ));

      // Ensure AuthGate widget is found
      expect(find.byType(AuthGate), findsOneWidget);
    });

    testWidgets('Navigation to Login Screen', (tester) async {
      MockFirebaseAuth mockAuth = MockFirebaseAuth();
      FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(firebaseAuth: mockAuth),
          ),
        ],
        child: MaterialApp(
          routes: {
            '/auth_gate': (context) => AuthGate(fireauth: mockAuth, firestore: fakeFirestore),
            '/fix_account': (context) => FixAccountPage(),
            '/login': (context) => LoginScreen(),
            '/signup': (context) => SignUpScreen(),
          },
          home: App(firestore: fakeFirestore, fireauth: mockAuth),
        ),
      ));

      await tester.pumpAndSettle();

      // Check if the LoginScreen is displayed
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
