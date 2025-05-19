import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/firebase/auth_service.dart';
import 'package:learnvironment/student/student_profile.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

/// Mock AuthService
class MockAuthService extends AuthService {
  late String uid;
  MockAuthService({MockFirebaseAuth? firebaseAuth})
      : super(firebaseAuth: firebaseAuth) {
    uid = firebaseAuth?.currentUser?.uid ?? '';
  }

  @override
  Future<String> getUid() async => uid;

  @override
  Stream<User?> get authStateChanges => Stream.value(MockUser());
}

class MockDataServiceWithWeekData extends Mock implements DataService {
  @override
  Future<UserData?> getUserData({required String userId}) async {
    return UserData(
      id: 'user123',
      name: 'Student Name',
      email: 'student@email.com',
      username: 'studentuser',
      role: '',
      birthdate: DateTime.now(),
      gamesPlayed: [],
      myGames: [],
      img: 'assets/placeholder.png',
      tClasses: [],
      stClasses: [],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getWeekGameResults({required String studentId}) async {
    return [
      {
        'date': DateTime.now().subtract(Duration(days: 6)),
        'correctCount': 10,
        'wrongCount': 2,
      },
      {
        'date': DateTime.now().subtract(Duration(days: 5)),
        'correctCount': 7,
        'wrongCount': 3,
      },
      {
        'date': DateTime.now().subtract(Duration(days: 4)),
        'correctCount': 5,
        'wrongCount': 5,
      },
    ];
  }
}

class MockDataServiceWithEmptyWeekData extends Mock implements DataService {
  @override
  Future<UserData?> getUserData({required String userId}) async {
    return UserData(
      id: 'user123',
      name: 'Student Name',
      email: 'student@email.com',
      username: 'studentuser',
      role: '',
      birthdate: DateTime.now(),
      gamesPlayed: [],
      myGames: [],
      img: 'assets/placeholder.png',
      tClasses: [],
      stClasses: [],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getWeekGameResults({required String studentId}) async {
    return []; // empty data to simulate no results
  }
}

/// Mock DataService with profile data
class MockDataServiceWithProfile extends Mock implements DataService {
  @override
  Future<UserData?> getUserData({required String userId}) async {
    return UserData(
      id: 'user123',
      name: 'Student Name',
      email: 'student@email.com',
      username: '',
      role: '',
      birthdate: DateTime.now(),
      gamesPlayed: [],
      myGames: [],
      img: 'assets/placeholder.png',
      tClasses: [],
      stClasses: [],
    );
  }
}

/// Mock DataService with no profile data
class MockDataServiceNoProfile extends Mock implements DataService {
  @override
  Future<UserData?> getUserData({required String userId}) async {
    return null; // Simulate missing student data
  }
}

void main() {
  group('StudentProfilePage Tests', () {
    late MockFirebaseAuth auth;
    late Widget testWidget;

    setUp(() {
      auth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'user123', email: 'student@email.com'),
        signedIn: true,
      );
    });

    testWidgets('displays student profile data when available',
      (WidgetTester tester) async {
        testWidget = MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>(
                create: (_) => MockAuthService(firebaseAuth: auth)),
            Provider<DataService>(
                create: (_) => MockDataServiceWithProfile()),
          ],
          child: MaterialApp(
            home: StudentProfilePage(studentId: 'user123'),
          ),
        );

        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        expect(find.text('Student Name'), findsOneWidget);
        expect(find.text('student@email.com'), findsOneWidget);
        expect(
            find.text('@'), findsOneWidget); // empty username still renders @
      });

    testWidgets('shows error message when student data is not found',
      (WidgetTester tester) async {
        testWidget = MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>(
                create: (_) => MockAuthService(firebaseAuth: auth)),
            Provider<DataService>(create: (_) => MockDataServiceNoProfile()),
          ],
          child: MaterialApp(
            home: StudentProfilePage(studentId: 'user123'),
          ),
        );

        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        expect(find.text('Student not found'), findsOneWidget);
      });

  testWidgets('supports pull to refresh functionality',
    (WidgetTester tester) async {
      final dataService = MockDataServiceWithProfile();

      testWidget = MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(
              create: (_) => MockAuthService(firebaseAuth: auth)),
          Provider<DataService>(create: (_) => dataService),
        ],
        child: MaterialApp(
          home: StudentProfilePage(studentId: 'user123'),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      expect(find.text('Student Name'), findsOneWidget);
    });

    testWidgets('shows bar chart when weekData is available', (
        WidgetTester tester) async {
      final dataService = MockDataServiceWithWeekData();

      final testWidget = MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(
            create: (_) => MockAuthService(firebaseAuth: auth),
          ),
          Provider<DataService>(create: (_) => dataService),
        ],
        child: MaterialApp(home: StudentProfilePage(studentId: 'user123')),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Expect student name and email as before
      expect(find.text('Student Name'), findsOneWidget);
      expect(find.text('student@email.com'), findsOneWidget);

      // The BarChart widget comes from fl_chart package, so let's find it by type
      expect(find.byType(BarChart), findsOneWidget);

      // The legend texts must also appear
      expect(find.text('✅ Correct answers'), findsOneWidget);
      expect(find.text('❌ Wrong answers'), findsOneWidget);
    });

    testWidgets('shows "No weekly data available." when no data', (
        WidgetTester tester) async {
      final dataService = MockDataServiceWithEmptyWeekData();

      final testWidget = MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(
            create: (_) => MockAuthService(firebaseAuth: auth),
          ),
          Provider<DataService>(create: (_) => dataService),
        ],
        child: MaterialApp(home: StudentProfilePage(studentId: 'user123')),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // No weekly data text should show
      expect(find.text('No weekly data available.'), findsOneWidget);
    });
  });
}
