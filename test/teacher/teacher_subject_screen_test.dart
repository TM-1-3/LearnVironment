import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/subject_data.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/teacher/classes/teacher_subject_screen.dart';
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

class MockDataService extends Mock implements DataService {
  bool throwErrorOnDelete = false;
  bool throwErrorOnAddStudent = false;
  bool throwErrorOnRemoveStudent = false;
  bool throwErrorAlreadyExistingStudent = false;

  void setThrowErrorOnDelete(bool value) {
    throwErrorOnDelete = value;
  }

  void setThrowErrorOnAddStudent(bool value) {
    throwErrorOnAddStudent = value;
  }

  void setThrowErrorOnRemoveStudent(bool value) {
    throwErrorOnRemoveStudent = value;
  }

  void setThrowErrorAlreadyExistingStudent(bool value){
    throwErrorAlreadyExistingStudent = value;
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
      username: 'user_$userId',
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
    if (throwErrorAlreadyExistingStudent){
      throw Exception('Student is already in this subject');
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
  Future<String?> getUserIdByUserName(String username) async {
    if (username=='NonExisting Student'){
      return null;
    }
    return username;
  }

  @override
  Future<bool> checkIfStudentAlreadyInClass({required String subjectId, required String studentId}) async {
    if (studentId=='user_student1' || studentId=='user_student2'){
      return true;
    }
    return false;
  }
}


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

      await tester.pumpAndSettle();
      final allTextWidgets = find.byType(Text);
      allTextWidgets.evaluate().forEach((element) {
        final widget = element.widget;
        if (widget is Text) print('Text: "${widget.data}"');
      });

      expect(find.text('user_student1'), findsOneWidget);
      expect(find.text('user_student2'), findsOneWidget);
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
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.textContaining('Failed to delete subject'), findsOneWidget);
    });

    testWidgets('shows Add Student dialog and adds a student successfully', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();


      await tester.ensureVisible(find.byKey(Key("addStudent")));
      await tester.tap(find.byKey(Key("addStudent")));
      await tester.pumpAndSettle();


      await tester.enterText(find.byType(TextField), 'student 3');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pump(); // Begin async call
      await tester.pump(const Duration(milliseconds: 500));


      expect(find.textContaining('Student added successfully'), findsOneWidget);
    });

    testWidgets('shows snackbar on student invalid username', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Tap the "Add Student" button
      await tester.ensureVisible(find.byKey(Key("addStudent")));
      await tester.tap(find.byKey(Key("addStudent")));
      await tester.pumpAndSettle();


      await tester.enterText(find.byType(TextField), 'NonExisting Student');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pump(); // Begin async call
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Student Not Found'), findsOneWidget);
    });

    testWidgets('shows snackbar on student add failure', (tester) async {
      mockDataService.setThrowErrorOnAddStudent(true);
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();


      await tester.ensureVisible(find.byKey(Key("addStudent")));
      await tester.tap(find.byKey(Key("addStudent")));
      await tester.pumpAndSettle();


      await tester.enterText(find.byType(TextField), 'errorStudentId');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Failed to add student'), findsOneWidget);
    });

    testWidgets('shows snackbar on adding student already in subject', (tester) async {
      mockDataService.setThrowErrorAlreadyExistingStudent(true);
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Tap the "Add Student" button
      await tester.ensureVisible(find.byKey(Key("addStudent")));
      await tester.tap(find.byKey(Key("addStudent")));
      await tester.pumpAndSettle();

      // Enter invalid student Username
      await tester.enterText(find.byType(TextField), 'user_student1');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pump(); // Begin async call
      await tester.pump(const Duration(seconds: 1)); // Wait for async work

      expect(find.text('Student is already in this subject'), findsOneWidget);
    });

    testWidgets('removes a student successfully', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();


      final removeButton = find.widgetWithIcon(IconButton, Icons.remove_circle_outline).first;
      await tester.tap(removeButton);
      await tester.pumpAndSettle();


      expect(find.text('Remove Student'), findsOneWidget);
      expect(find.text('Are you sure you want to remove this student from the class?'), findsOneWidget);


      await tester.tap(find.widgetWithText(ElevatedButton, 'Remove'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));


      expect(find.text('Student removed successfully'), findsOneWidget);


      expect(find.text('Student student1'), findsNothing);
    });

    testWidgets('shows snackbar on student remove failure', (tester) async {
      mockDataService.setThrowErrorOnRemoveStudent(true);

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();


      final removeButton = find.widgetWithIcon(IconButton, Icons.remove_circle_outline).first;
      await tester.tap(removeButton);
      await tester.pumpAndSettle();


      await tester.tap(find.widgetWithText(ElevatedButton, 'Remove'));
      await tester.pump(); // Begin async
      await tester.pump(const Duration(seconds: 1)); // Finish async


      expect(find.text('Failed to remove student'), findsOneWidget);


      expect(find.text('Student student1'), findsOneWidget);
    });
  });
}
