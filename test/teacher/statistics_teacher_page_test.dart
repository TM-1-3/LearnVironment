import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/subject_data.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/services/cache/user_cache_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/firebase/auth_service.dart';
import 'package:learnvironment/teacher/statistics_teacher_page.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:learnvironment/authentication/auth_gate.dart';

import '../main_pages/editprofilescreen_test.dart';


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
  }

  @override
  Future<SubjectData?> getSubjectData({required String subjectId, required bool forceRefresh}) async {
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

void main() {
  late MockFirebaseAuth auth;
  late MockAuthService authService;
  late MockUserCache userCache;
  late MockDataService dataService;

  setUp(() {
    auth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'test', email: 'john@example.com'),
        signedIn: true);
    authService = MockAuthService(firebaseAuth: auth);
    userCache = MockUserCache();
    dataService = MockDataService();
  });

  Widget createTestWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => authService),
        Provider<DataService>(create: (_) => dataService),
        Provider<UserCacheService>(create: (_) => userCache),
      ],
      child: MaterialApp(
        home: Material(child: child),
        routes: {
          '/auth_gate': (context) => MockAuthGate(),
        },
      ),
    );
  }

  group('StatisticsTeacherPage Widget Tests', () {


    testWidgets('shows message when no students exist for selected class', (tester) async {
      await tester.pumpWidget(createTestWidget(const StatisticsTeacherPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('DropdownButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Class B').last);
      await tester.pumpAndSettle();

      expect(find.text('No student data available.'), findsOneWidget);
    });


  });
}
