import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/subject_data.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/firebase/auth_service.dart';
import 'package:learnvironment/teacher/statistics_teacher_page.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

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
  Future<SubjectData?> getSubjectData({required String subjectId}) async {
    if (subjectId == 'Class A') {
      return SubjectData(
        subjectId: 'Class A',
        subjectName: 'Class A',
        teacher: 'teacher1',
        students: [
          {'studentId': 'student1', 'correctCount': 5, 'wrongCount': 2},
          {'studentId': 'student2', 'correctCount': 3, 'wrongCount': 4},
        ],
        subjectLogo: '',
        assignments: [],
      );
    } else if (subjectId == 'Class B') {
      return SubjectData(
        subjectId: 'Class B',
        subjectName: 'Class B',
        teacher: 'teacher1',
        students: [],
        subjectLogo: '',
        assignments: [],
      );
    }
    return null;
  }
}

class MockAuthService extends Mock implements AuthService {
  @override
  Future<String> getUid() async => 'teacher1';
}

void main() {
  late MockDataService mockDataService;
  late MockAuthService mockAuthService;
  late Widget testWidget;

  setUp(() {
    mockDataService = MockDataService();
    mockAuthService = MockAuthService();

    testWidget = MultiProvider(
      providers: [
        Provider<DataService>(create: (_) => mockDataService),
        Provider<AuthService>(create: (_) => mockAuthService),
      ],
      child: const MaterialApp(home: StatisticsTeacherPage()),
    );
  });

  group('StatisticsTeacherPage Widget Tests', () {
    testWidgets('shows dropdown and chart when a class is selected', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Open the dropdown
      await tester.ensureVisible(find.byKey(Key('DropdownButton')));
      await tester.tap(find.byKey(Key('DropdownButton')));
      await tester.pump(); // just a short pump first
      await tester.pump(const Duration(seconds: 1)); // then a longer one


      // ✅ Wait until Class A shows up
      expect(find.text('Class A'), findsWidgets); // Use `findsWidgets` not `findsOneWidget`

      // Tap the menu item
      await tester.tap(find.text('Class A').last);
      await tester.pumpAndSettle();

      // Verify chart & names
      expect(find.byType(BarChart), findsOneWidget);
      expect(find.text('student1'), findsOneWidget); // Should be the name from `getUserData`
      expect(find.text('student2'), findsOneWidget);
    });


    testWidgets('shows message when no students exist for selected class', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('DropdownButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Class B').last);
      await tester.pumpAndSettle();

      expect(find.text('No student data available.'), findsOneWidget);
    });

    testWidgets('refresh button reloads class list', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<SubjectData>), findsOneWidget);
    });
  });
}
