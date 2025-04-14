import 'package:learnvironment/authentication/auth_gate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:learnvironment/authentication/fix_account.dart';
import 'package:learnvironment/developer/developer_home.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/firestore_service.dart';
import 'package:learnvironment/student/student_home.dart';
import 'package:learnvironment/teacher/teacher_home.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockFirestoreService extends FirestoreService {
  MockFirestoreService({super.firestore});}

void main() {
    group('AuthGate - Widget Navigation Tests', () {
      late FakeFirebaseFirestore fakeFirestore;
      late MockFirebaseAuth mockAuth;
      late Widget testWidget;
      late MockNavigatorObserver mockNavigatorObserver;

      setUp(() {
        fakeFirestore = FakeFirebaseFirestore();
        mockNavigatorObserver = MockNavigatorObserver();
      });

      testWidgets('Navigates to Developer home screen', (
          WidgetTester tester,
          ) async {
        mockAuth = MockFirebaseAuth(signedIn: true,
          mockUser: MockUser(
            uid: 'testDeveloper',
            email: 'test@example.com',
            displayName: 'Test User',
          ),);

        await fakeFirestore.collection('users').doc('testDeveloper').set({
          'role': 'developer', // Mock user role in Firestore
        });

        testWidget = MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>(
              create: (_) => AuthService(firebaseAuth: mockAuth),
            ),
          ],
          child: MaterialApp(
            home: AuthGate(),
            navigatorObservers: [mockNavigatorObserver],
          ),
        );

        // Render the widget and wait for UI updates
        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        // Verify navigation to DeveloperHomePage
        expect(find.byType(DeveloperHomePage), findsOneWidget);
      });

      testWidgets('Navigates to Student home screen', (
          WidgetTester tester,
          ) async {
        mockAuth = MockFirebaseAuth(signedIn: true,
          mockUser: MockUser(
            uid: 'testDeveloper',
            email: 'test@example.com',
            displayName: 'Test User',
          ),);

        await fakeFirestore.collection('users').doc('testDeveloper').set({
          'role': 'student', // Mock user role in Firestore
        });

        testWidget = MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>(
              create: (_) => AuthService(firebaseAuth: mockAuth),
            ),
          ],
          child: MaterialApp(
            home: AuthGate(),
            navigatorObservers: [mockNavigatorObserver],
          ),
        );

        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        expect(find.byType(StudentHomePage), findsOneWidget);
      });

      testWidgets('Navigates to Teacher home screen', (
          WidgetTester tester,
          ) async {
        mockAuth = MockFirebaseAuth(signedIn: true,
          mockUser: MockUser(
            uid: 'testDeveloper',
            email: 'test@example.com',
            displayName: 'Test User',
          ),);

        await fakeFirestore.collection('users').doc('testDeveloper').set({
          'role': 'teacher', // Mock user role in Firestore
        });

        testWidget = MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>(
              create: (_) => AuthService(firebaseAuth: mockAuth),
            ),
          ],
          child: MaterialApp(
            home: AuthGate(),
            navigatorObservers: [mockNavigatorObserver],
          ),
        );

        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        expect(find.byType(TeacherHomePage), findsOneWidget);
      });

      testWidgets('Navigates to FixAccountPage home screen', (
          WidgetTester tester,
          ) async {
        mockAuth = MockFirebaseAuth(signedIn: true,
          mockUser: MockUser(
            uid: 'testDeveloper',
            email: 'test@example.com',
            displayName: 'Test User',
          ),);

        await fakeFirestore.collection('users').doc('testDeveloper').set({
          'role': '', // Mock user role in Firestore
        });
        AuthGate authGate = AuthGate();

        testWidget = MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>(
              create: (_) => AuthService(firebaseAuth: mockAuth),
            ),
          ],
          child: MaterialApp(
            home: authGate,
            navigatorObservers: [mockNavigatorObserver],
          ),
        );

        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        expect(find.byType(FixAccountPage), findsOneWidget);
      });
  });
  }