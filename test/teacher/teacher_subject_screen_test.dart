import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/subject_data.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/teacher/teacher_subject_screen.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Mock class
class MockDataService extends Mock implements DataService {
  bool throwErrorOnDelete = false;

  void setThrowErrorOnDelete(bool value) {
    throwErrorOnDelete = value;
  }

  @override
  Future<void> deleteSubject({required String subjectId}) async {
    if (throwErrorOnDelete) {
      throw Exception('Failed to delete subject');
    }
  }

  @override
  Future<UserData?> getUserData({required String userId}) async {
    return UserData(
      name: 'Student $userId',
      email: '$userId@example.com',
      id: userId,
      username: '',
      role: '',
      birthdate: DateTime(2000, 1, 1),
      gamesPlayed: [],
      img: '',
      classes: [],
      // add any other fields if needed, depending on your UserData constructor
    );
  }
}

// Helper class to fake user data
class FakeUserData {
  final String name;
  final String email;

  FakeUserData({required this.name, required this.email});
}

void main() {
  late MockDataService mockDataService;
  late SubjectData subjectData;
  late Widget testWidget;

  setUp(() {
    mockDataService = MockDataService();

    subjectData = SubjectData(
      subjectId: 'subject123',
      subjectName: 'Physics',
      subjectLogo: 'assets/placeholder.png',
      students: ['student1', 'student2'],
      teacher: 'teacher',
    );

    testWidget = MultiProvider(
      providers: [
        Provider<DataService>(create: (_) => mockDataService),
      ],
      child: MaterialApp(
        home: TeacherSubjectScreen(subjectData: subjectData),
      ),
    );
  });

  group('TeacherSubjectScreen Tests', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.text('Physics'), findsExactly(2));
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Enrolled Students'), findsOneWidget);
    });

    testWidgets('displays students', (tester) async {
      await tester.pumpWidget(testWidget);

      await tester.pumpAndSettle(); // Wait for FutureBuilders

      expect(find.text('Student student1'), findsOneWidget);
      expect(find.text('Student student2'), findsOneWidget);
    });

    testWidgets('shows "No students enrolled yet." if no students', (tester) async {
      subjectData = SubjectData(
        subjectId: 'subjectEmpty',
        subjectName: 'Empty Class',
        subjectLogo: 'assets/placeholder.png',
        students: [],
        teacher: 'teacher',
      );

      testWidget = MultiProvider(
        providers: [
          Provider<DataService>(create: (_) => mockDataService),
        ],
        child: MaterialApp(
          home: TeacherSubjectScreen(subjectData: subjectData),
        ),
      );

      await tester.pumpWidget(testWidget);

      expect(find.text('No students enrolled yet.'), findsOneWidget);
    });

    testWidgets('shows delete confirmation dialog', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(Key("delete")));
      await tester.tap(find.byKey(Key("delete")));
      await tester.pumpAndSettle();

      expect(find.text('Delete Subject'), findsExactly(2));
      expect(find.text('Are you sure you want to delete this subject? This action cannot be undone.'), findsOneWidget);
    });

    testWidgets('shows snackbar on delete error', (tester) async {
      mockDataService.setThrowErrorOnDelete(true);
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(Key("delete")));
      await tester.tap(find.byKey(Key("delete")));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
      await tester.pump(); // Start async
      await tester.pump(const Duration(seconds: 1)); // Finish async

      expect(find.textContaining('Failed to delete subject'), findsOneWidget);
    });
  });
}
