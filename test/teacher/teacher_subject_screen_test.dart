import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/subject_data.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/teacher/teacher_subject_screen.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
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
// Mock class
class MockDataService extends Mock implements DataService {
  bool throwErrorOnDelete = false;
  bool throwErrorOnAddStudent = false;
  bool throwErrorOnRemoveStudent = false;

  void setThrowErrorOnDelete(bool value) {
    throwErrorOnDelete = value;
  }

  void setThrowErrorOnAddStudent(bool value) {
    throwErrorOnAddStudent = value;
  }

  void setThrowErrorOnRemoveStudent(bool value) {
    throwErrorOnRemoveStudent = value;
  }

  @override
  Future<void> deleteSubject(
      {required String subjectId, required String uid}) async {
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
      myGames: [],
      img: '',
      stClasses: ['class1', 'class2'],
      tClasses: ['tClass1', 'tClass2']
    );
  }

  @override
  Future<void> addStudentToSubject(
      {required String subjectId, required String studentId}) async {
    if (throwErrorOnAddStudent) {
      throw Exception('Failed to add student');
    }
  }

  @override
  Future<void> removeStudentFromSubject(
      {required String subjectId, required String studentId}) async {
    if (throwErrorOnRemoveStudent) {
      throw Exception('Failed to remove student');
    }
  }

  @override
  Future<String?> getUserIdByName(String name) async {
    if (name=='NonExisting Student'){
      return null;
    }
    return name;
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
      students: [{'studentId':'student1', 'correctCount':1, 'wrongCount':2}, {'studentId':'student2', 'correctCount':5, 'wrongCount':5}],
      assignments: ['assignment1', 'assignment2'],
      teacher: 'teacher',
    );

    testWidget = MultiProvider(
      providers: [
        Provider<DataService>(create: (_) => mockDataService),
      ],
      child: MaterialApp(
        home: TeacherSubjectScreen(subjectData: subjectData),
        routes: {
          '/auth_gate': (context) => MockAuthGate(),
        },
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
        assignments: [],
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

    testWidgets('shows Add Student dialog and adds a student successfully', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Tap the "Add Student" button
      await tester.ensureVisible(find.byKey(Key("addStudent")));
      await tester.tap(find.byKey(Key("addStudent")));
      await tester.pumpAndSettle();

      // Enter student ID
      await tester.enterText(find.byType(TextField), 'student 3');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pump(); // Begin async call
      await tester.pump(const Duration(milliseconds: 500));

      // Check snackbar shows success message
      expect(find.textContaining('Student added successfully'), findsOneWidget);
    });

    testWidgets('shows snackbar on student invalid name', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Tap the "Add Student" button
      await tester.ensureVisible(find.byKey(Key("addStudent")));
      await tester.tap(find.byKey(Key("addStudent")));
      await tester.pumpAndSettle();

      // Enter invalid student Name
      await tester.enterText(find.byType(TextField), 'NonExisting Student');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pump(); // Begin async call
      await tester.pump(const Duration(seconds: 1)); // Wait for async work

      expect(find.text('Student Not Found'), findsOneWidget);
    });

    testWidgets('shows snackbar on student add failure', (tester) async {
      mockDataService.setThrowErrorOnAddStudent(true);
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Tap the "Add Student" button
      await tester.ensureVisible(find.byKey(Key("addStudent")));
      await tester.tap(find.byKey(Key("addStudent")));
      await tester.pumpAndSettle();

      // Enter invalid student ID
      await tester.enterText(find.byType(TextField), 'errorStudentId');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pump(); // Begin async call
      await tester.pump(const Duration(seconds: 1)); // Wait for async work

      expect(find.text('Failed to add student'), findsOneWidget);
    });

    testWidgets('removes a student successfully', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle(); // Allow FutureBuilders to complete

      // Find and tap the remove icon for the first student
      final removeButton = find.widgetWithIcon(IconButton, Icons.remove_circle_outline).first;
      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      // Confirm the dialog appears
      expect(find.text('Remove Student'), findsOneWidget);
      expect(find.text('Are you sure you want to remove this student from the class?'), findsOneWidget);

      // Tap 'Remove' button in dialog
      await tester.tap(find.widgetWithText(ElevatedButton, 'Remove'));
      await tester.pump(); // Begin async
      await tester.pump(const Duration(seconds: 1)); // Complete async

      // Success snackbar shown
      expect(find.text('Student removed successfully'), findsOneWidget);

      // Student should no longer be in the widget tree
      expect(find.text('Student student1'), findsNothing);
    });

    testWidgets('shows snackbar on student remove failure', (tester) async {
      mockDataService.setThrowErrorOnRemoveStudent(true);

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle(); // Wait for student list

      // Find and tap remove icon
      final removeButton = find.widgetWithIcon(IconButton, Icons.remove_circle_outline).first;
      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      // Confirm dialog appears and tap remove
      await tester.tap(find.widgetWithText(ElevatedButton, 'Remove'));
      await tester.pump(); // Begin async
      await tester.pump(const Duration(seconds: 1)); // Finish async

      // Error snackbar shown
      expect(find.text('Failed to remove student'), findsOneWidget);

      // Student should still be present
      expect(find.text('Student student1'), findsOneWidget);
    });
  });
}
