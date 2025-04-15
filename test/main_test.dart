import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/authentication/fix_account.dart';
import 'package:learnvironment/authentication/login_screen.dart';
import 'package:learnvironment/authentication/signup_screen.dart';
import 'package:learnvironment/main.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/firestore_service.dart';
import 'package:learnvironment/services/game_cache_service.dart';
import 'package:learnvironment/services/user_cache_service.dart';
import 'package:provider/provider.dart';
import 'package:learnvironment/authentication/auth_gate.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() async {
    testWidgets('App Initialization Is OK', (tester) async {
      MockFirebaseAuth mockAuth = MockFirebaseAuth(mockUser: MockUser(
        uid: 'test-uid',
        email: 'test@example.com',
        isAnonymous: false,
      ), signedIn: false);
      FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final authService = AuthService(firebaseAuth: mockAuth);
      await authService.init();
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(create: (_) => authService),
          Provider<FirestoreService>(create: (_) => FirestoreService(firestore: firestore)),
          Provider<UserCacheService>(create: (_) => UserCacheService()),
          Provider<GameCacheService>(create: (_) => GameCacheService()),
          Provider<DataService>(create: (context) => DataService(context)),
        ],
        child: MaterialApp(
          routes: {
            '/auth_gate': (context) => AuthGate(),
            '/fix_account': (context) => FixAccountPage(),
            '/login': (context) => LoginScreen(),
            '/signup': (context) => SignUpScreen(),
          },
          home: App(),
        ),
      ));
      expect(
        Provider.of<AuthService>(
            tester.element(find.byType(App)), listen: false),
        isNotNull,
      );
      expect(find.byType(AuthGate), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('App Initialization Is OK - signed in user', (tester) async {
      MockFirebaseAuth mockAuth = MockFirebaseAuth(mockUser: MockUser(
        uid: 'test-uid',
        email: 'test@example.com',
        isAnonymous: false,
      ), signedIn: true);
      FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final authService = AuthService(firebaseAuth: mockAuth);
      await authService.init();
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(create: (_) => authService),
          Provider<FirestoreService>(create: (_) => FirestoreService(firestore: firestore)),
          Provider<UserCacheService>(create: (_) => UserCacheService()),
          Provider<GameCacheService>(create: (_) => GameCacheService()),
          Provider<DataService>(create: (context) => DataService(context)),
        ],
        child: MaterialApp(
          routes: {
            '/auth_gate': (context) => AuthGate(),
            '/fix_account': (context) => FixAccountPage(),
            '/login': (context) => LoginScreen(),
            '/signup': (context) => SignUpScreen(),
          },
          home: App(),
        ),
      ));
      expect(
        Provider.of<AuthService>(
            tester.element(find.byType(App)), listen: false),
        isNotNull,
      );
      expect(find.byType(AuthGate), findsOneWidget);
    });
}
