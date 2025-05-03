import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:learnvironment/authentication/auth_gate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/authentication/fix_account.dart';
import 'package:learnvironment/developer/developer_home.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/firebase_messaging_service.dart';
import 'package:learnvironment/services/firestore_service.dart';
import 'package:learnvironment/student/student_home.dart';
import 'package:learnvironment/teacher/teacher_home.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:learnvironment/data/user_data.dart';

class MockAuthService extends Mock implements AuthService {
  late bool _loggedIn;
  late bool _fetchedNotifications;
  late String uid;

  @override
  bool get loggedIn => _loggedIn;

  @override
  bool get fetchedNotifications => _fetchedNotifications;

  @override
  set loggedIn(bool value) {
    _loggedIn = value;
  }

  @override
  set fetchedNotifications(bool value) {
    _fetchedNotifications = value;
  }

  MockAuthService({MockFirebaseAuth? firebaseAuth}) {
    loggedIn = firebaseAuth?.currentUser != null;
    uid = firebaseAuth?.currentUser?.uid ?? '';
    fetchedNotifications = true;
  }

  @override
  Future<String> getUid() async {
    return uid;
  }

  @override
  Stream<User?> get authStateChanges => Stream.value(MockUser());
}

class MockDataService extends Mock implements DataService {
  @override
  Future<UserData?> getUserData({required String userId}) {
    if (userId == 'testDeveloper') {
      return Future.value(UserData(role: 'developer', id: 'testDeveloper', username: 'Test User', email: 'test@example.com', name: 'Dev', birthdate: DateTime(2000, 1, 1, 0, 0, 0, 0, 0), gamesPlayed: [], stClasses: [], tClasses: [], img: ''));
    } else if (userId == 'testStudent') {
      return Future.value(UserData(role: 'student', id: '', username: '', email: '', name: '', birthdate: DateTime(2000, 1, 1, 0, 0, 0, 0, 0), gamesPlayed: [], stClasses: [], tClasses: [], img: ''));
    } else if (userId == 'testTeacher') {
      return Future.value(UserData(role: 'teacher', id: '', username: '', email: '', name: '', birthdate: DateTime(2000, 1, 1, 0, 0, 0, 0, 0), gamesPlayed: [], stClasses: [], tClasses: [], img: ''));
    } else if (userId == 'error') {
      throw Exception('Error loading user data');
    } else {
      return Future.value(UserData(role: '', id: '', username: '', email: '', name: '', birthdate: DateTime(2000, 1, 1, 0, 0, 0, 0, 0), gamesPlayed: [], stClasses: [], tClasses: [], img: ''));
    }
  }
}

class MockFirestoreService extends Mock implements FirestoreService {
  @override
  Future<List<RemoteMessage>> fetchNotifications({required String uid}) async {
    return [];
  }
}
class MockFirebaseMessagingService extends Mock implements FirebaseMessagingService {}

void main() {
  group('AuthGate - Widget Navigation Tests', () {
    late MockFirebaseAuth mockAuth;
    late Widget testWidget;
    late MockDataService mockDataService;
    late MockFirebaseMessagingService firebaseMessagingService;
    late MockFirestoreService mockFirestoreService;
    late AuthService authService;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockDataService = MockDataService();
      firebaseMessagingService = MockFirebaseMessagingService();
      mockFirestoreService = MockFirestoreService();
    });

    testWidgets('Navigates to Developer home screen', (WidgetTester tester) async {
      mockAuth = MockFirebaseAuth(signedIn: true,
        mockUser: MockUser(
          uid: 'testDeveloper',
          email: 'test@example.com',
          displayName: 'Test User',
        ),
      );

      authService = MockAuthService(firebaseAuth: mockAuth);
      authService.fetchedNotifications = true;

      testWidget = MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(
            create: (_) => authService,
          ),
          Provider<DataService>(create: (_) => mockDataService),
          Provider<FirestoreService>(create: (_) => mockFirestoreService),
          Provider<FirebaseMessagingService>(create: (_) => firebaseMessagingService),
        ],
        child: MaterialApp(
          home: AuthGate(),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      expect(find.byType(DeveloperHomePage), findsOneWidget);
    });

    testWidgets('Navigates to Student home screen', (WidgetTester tester) async {
      mockAuth = MockFirebaseAuth(signedIn: true,
        mockUser: MockUser(
          uid: 'testStudent',
          email: 'test@example.com',
          displayName: 'Test User',
        ),
      );

      testWidget = MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(
            create: (_) => MockAuthService(firebaseAuth: mockAuth),
          ),
          Provider<DataService>(create: (_) => mockDataService),
          Provider<FirestoreService>(create: (_) => mockFirestoreService),
          Provider<FirebaseMessagingService>(create: (_) => firebaseMessagingService),
        ],
        child: MaterialApp(
          home: AuthGate(),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      expect(find.byType(StudentHomePage), findsOneWidget);
    });

    testWidgets('Navigates to Teacher home screen', (WidgetTester tester) async {
      mockAuth = MockFirebaseAuth(signedIn: true,
        mockUser: MockUser(
          uid: 'testTeacher',
          email: 'test@example.com',
          displayName: 'Test User',
        ),
      );

      testWidget = MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(create: (_) => MockAuthService(firebaseAuth: mockAuth)),
          Provider<DataService>(create: (_) => mockDataService),
          Provider<FirestoreService>(create: (_) => mockFirestoreService),
          Provider<FirebaseMessagingService>(create: (_) => firebaseMessagingService),
        ],
        child: MaterialApp(
          home: AuthGate(),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      expect(find.byType(TeacherHomePage), findsOneWidget);
    });

    testWidgets('Navigates to FixAccountPage home screen for empty role', (WidgetTester tester) async {
      mockAuth = MockFirebaseAuth(signedIn: true,
        mockUser: MockUser(
          uid: 'fdhlaf',
          email: 'test@example.com',
          displayName: 'Test User',
        ),
      );

      testWidget = MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(create: (_) => MockAuthService(firebaseAuth: mockAuth)),
          Provider<DataService>(create: (_) => mockDataService),
          Provider<FirestoreService>(create: (_) => mockFirestoreService),
          Provider<FirebaseMessagingService>(create: (_) => firebaseMessagingService),
        ],
        child: MaterialApp(
          home: AuthGate(),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      expect(find.byType(FixAccountPage), findsOneWidget);
    });

    testWidgets('Handles error when loading user data', (WidgetTester tester) async {
      mockAuth = MockFirebaseAuth(signedIn: true,
        mockUser: MockUser(
          uid: 'error',
          email: 'test@example.com',
          displayName: 'Test User',
        ),
      );

      testWidget = MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(create: (_) => MockAuthService(firebaseAuth: mockAuth)),
          Provider<DataService>(create: (_) => mockDataService),
          Provider<FirestoreService>(create: (_) => mockFirestoreService),
          Provider<FirebaseMessagingService>(create: (_) => firebaseMessagingService),
        ],
        child: MaterialApp(
          home: AuthGate(),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      expect(find.text('Error: Exception: Error loading user data'), findsOneWidget);
    });
  });
}
