import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/authentication/login_screen.dart';
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
  late Widget testWidget;
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore firestore;
  late AuthService authService;

  setUp((){
    mockAuth = MockFirebaseAuth(mockUser:
      MockUser(
        uid: 'test-uid',
        email: 'test@example.com',
        isAnonymous: false,
      ),
        signedIn: true);

    firestore = FakeFirebaseFirestore();
    authService = AuthService(firebaseAuth: mockAuth);

    testWidget = MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => authService),
        Provider<FirestoreService>(create: (_) => FirestoreService(firestore: firestore)),
        Provider<UserCacheService>(create: (_) => UserCacheService()),
        Provider<GameCacheService>(create: (_) => GameCacheService()),
        Provider<DataService>(create: (context) => DataService(context)),
      ],
      child: App(),
    );
  });

  testWidgets('App Initialization Is OK - signed out user', (tester) async {
    mockAuth = MockFirebaseAuth(mockUser:
    MockUser(
      uid: 'test-uid',
      email: 'test@example.com',
      isAnonymous: false,
    ),
        signedIn: false);
    testWidget = MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => authService),
        Provider<FirestoreService>(create: (_) => FirestoreService(firestore: firestore)),
        Provider<UserCacheService>(create: (_) => UserCacheService()),
        Provider<GameCacheService>(create: (_) => GameCacheService()),
        Provider<DataService>(create: (context) => DataService(context)),
      ],
      child: App(),
    );
    await tester.pumpWidget(testWidget);

    expect(find.byType(AuthGate), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('App Initialization Is OK - signed in user', (tester) async {
    await tester.pumpWidget(testWidget);
    expect(find.byType(AuthGate), findsOneWidget);
  });
}
