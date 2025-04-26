import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/subject_data.dart';
import 'package:learnvironment/teacher/subject_screen.dart';
import 'package:learnvironment/teacher/widgets/subject_card.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockAuthService extends AuthService {
  MockAuthService({MockFirebaseAuth? firebaseAuth})
      : super(firebaseAuth: firebaseAuth);

  @override
  Future<String> getUid() async {
    return 'user123';
  }

  @override
  Stream<User?> get authStateChanges => Stream.value(MockUser());
}

class MockDataService extends Mock implements DataService {
  @override
  Future<List<Map<String, dynamic>>> getAllSubjects({required String uid}) async {
    return [
      {
        'imagePath': 'assets/placeholder.png',
        'subjectName': 'Math',
        'subjectId': 'mock_subject_0',
      },
      {
        'imagePath': 'assets/placeholder.png',
        'subjectName': 'History',
        'subjectId': 'mock_subject_1',
      },
    ];
  }

  @override
  Future<SubjectData?> getSubjectData({required String subjectId}) async {
    return SubjectData(
      subjectName: 'Math',
      subjectLogo: 'assets/placeholder.png',
      subjectId: subjectId,
      teacher: '',
      students: [],
    );
  }
}

void main() {
  group('SubjectsPage Tests', () {
    late MockFirebaseAuth auth;
    late Widget testWidget;

    setUp(() async {
      auth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'user123', email: 'email@gmail.com'),
        signedIn: true,
      );

      testWidget = MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(create: (_) => MockAuthService(firebaseAuth: auth)),
          Provider<DataService>(create: (context) => MockDataService()),
        ],
        child: MaterialApp(
          home: SubjectScreen(
            subjectData: SubjectData(
              subjectName: 'Test Subject',
              subjectLogo: 'assets/placeholder.png',
              subjectId: 'test_subject',
              teacher: 'user123',
              students: [],
            ),
          ),
        ),
      );
    });

    testWidgets('should display search bar', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();
      expect(find.byKey(Key('subjectSearch')), findsOneWidget);
    });

    testWidgets('should filter subjects by search query', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      expect(find.byType(SubjectCard), findsNWidgets(2));
      await tester.enterText(find.byKey(Key('subjectSearch')), 'Math');
      await tester.pumpAndSettle();

      expect(find.text('Math'), findsOneWidget);
      expect(find.text('History'), findsNothing);
      expect(find.byType(SubjectCard), findsOneWidget);
    });

    testWidgets('should filter subjects by tag', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('subjectTagDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('STEM').last);
      await tester.pumpAndSettle();

      expect(find.text('Math'), findsOneWidget);
      expect(find.text('History'), findsNothing);
      expect(find.byType(SubjectCard), findsOneWidget);
    });

    testWidgets('should reset tag filter when "All Tags" is selected', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('subjectTagDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('STEM').last);
      await tester.pumpAndSettle();

      expect(find.byType(SubjectCard), findsOneWidget);

      await tester.tap(find.byKey(Key('subjectTagDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All Tags').last);
      await tester.pumpAndSettle();

      expect(find.byType(SubjectCard), findsNWidgets(2));
    });

    testWidgets('should navigate to subject details screen', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      final subjectCardKey = Key('subjectCard_mock_subject_0');
      expect(find.byKey(subjectCardKey), findsOneWidget);

      await tester.tap(find.byKey(subjectCardKey));
      await tester.pumpAndSettle();

      // This assumes after tapping you navigate to a page with 'Learn math!'
      // Adjust if needed based on your app.
      expect(find.text('Learn math!'), findsOneWidget);
    });

    testWidgets('should display no results found when no subjects match filters', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(Key('subjectSearch')), 'Nonexistent');
      await tester.pumpAndSettle();

      expect(find.text('No results found'), findsOneWidget);
    });
  });
}
