import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/subject_data.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/services/cache/subject_cache_service.dart';
import 'package:learnvironment/services/cache/user_cache_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/firebase/auth_service.dart';
import 'package:learnvironment/teacher/statistics_teacher_page.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:learnvironment/authentication/auth_gate.dart';

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

class MockDataService extends Mock implements DataService {
  @override
  Future<UserData?> getUserData({required String userId}) async {
    if (userId == 'teacher1') {
      return UserData(
        id: 'teacher1',
        name: 'Mr. Smith',
        email: 'smith@example.com',
        username: 'teacher1',
        role: 'teacher',
        birthdate: DateTime(1980, 5, 10),
        gamesPlayed: [],
        myGames: [],
        img: '',
        stClasses: [],
        tClasses: ['Class A', 'Class B'],
      );
    } else if (userId == 'student1') {
      return UserData(
        id: 'student1',
        name: 'Alice',
        email: 'alice@example.com',
        username: 'alice123',
        role: 'student',
        birthdate: DateTime(2005, 2, 14),
        gamesPlayed: [],
        myGames: [],
        img: '',
        stClasses: ['Class A'],
        tClasses: [],
      );
    } else if (userId == 'student2') {
      return UserData(
        id: 'student2',
        name: 'Bob',
        email: 'bob@example.com',
        username: 'bob321',
        role: 'student',
        birthdate: DateTime(2004, 8, 30),
        gamesPlayed: [],
        myGames: [],
        img: '',
        stClasses: ['Class A'],
        tClasses: [],
      );
    }

    return null;
  }


  @override
  Future<SubjectData?> getSubjectData({required String subjectId, bool forceRefresh = false}) async {
    if (subjectId == 'Class A') {
      return SubjectData(
        subjectId: 'Class A',
        subjectName: 'Class A',
        teacher: 'teacher1',
        students: [
          {'studentId': 'student1', 'correctCount': 5, 'wrongCount': 2},
          {'studentId': 'student2', 'correctCount': 3, 'wrongCount': 4},
        ],
        subjectLogo: 'placeholder.png',
        assignments: [],
      );
    } else if (subjectId == 'Class B') {
      return SubjectData(
        subjectId: 'Class B',
        subjectName: 'Class B',
        teacher: 'teacher1',
        students: [],
        subjectLogo: 'placeholder.png',
        assignments: [],
      );
    }
    return null;
  }
}

class MockAuthService extends Mock implements AuthService {
  late String uid;

  @override
  Future<String> getUid() async => 'teacher1';

  MockAuthService({MockFirebaseAuth? firebaseAuth}) {
    uid = firebaseAuth?.currentUser?.uid ?? '';
  }
}

class MockUserCache extends Mock implements UserCacheService {}
class MockSubjectCacheService extends Mock implements SubjectCacheService {}


void main() {
  late MockFirebaseAuth auth;
  late MockAuthService authService;
  late MockUserCache userCache;
  late MockDataService dataService;
  late MockSubjectCacheService subjectCache;


  setUp(() {
    auth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'test', email: 'john@example.com'),
        signedIn: true);
    authService = MockAuthService(firebaseAuth: auth);
    userCache = MockUserCache();
    dataService = MockDataService();
    subjectCache = MockSubjectCacheService();

  });

  Widget createTestWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => authService),
        Provider<DataService>(create: (_) => dataService),
        Provider<UserCacheService>(create: (_) => userCache),
        Provider<SubjectCacheService>(create: (_) => subjectCache),
      ],
      child: MaterialApp(
        home: Material(child: child), // 🟢 Add Material ancestor
        routes: {
          '/auth_gate': (context) => MockAuthGate(),
        },
      ),
    );
  }

  group('StatisticsTeacherPage Widget Tests', () {
    testWidgets('Shows dropdown and chart when a class is selected', (tester) async {
      await tester.pumpWidget(createTestWidget(const StatisticsTeacherPage()));
      await tester.pumpAndSettle();

      final dropdownFinder = find.byKey(const Key('DropdownButton'));
      await tester.ensureVisible(dropdownFinder);
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      expect(find.text('Class A'), findsWidgets);
      await tester.tap(find.text('Class A').last);
      await tester.pumpAndSettle();

      expect(find.byType(BarChart), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('shows message when no students exist for selected class', (tester) async {
      await tester.pumpWidget(createTestWidget(const StatisticsTeacherPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('DropdownButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Class B').last);
      await tester.pumpAndSettle();

      expect(find.text('No student data available.'), findsOneWidget);
    });

    testWidgets('refresh button reloads class list', (tester) async {
      await tester.pumpWidget(createTestWidget(const StatisticsTeacherPage()));
      await tester.pumpAndSettle();

      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('DropdownButton')), findsOneWidget);
    });
  });
}