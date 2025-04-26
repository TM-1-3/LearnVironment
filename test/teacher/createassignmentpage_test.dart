import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/authentication/auth_gate.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/teacher/create_assignment_page.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

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
  bool _throwErrorOnSave = false;
  void setThrowErrorOnSave(bool value) {
    _throwErrorOnSave = value;
  }
  @override
  Future<UserData?> getUserData({required String userId}) async {
    if (userId == 'error') {
      return null;
    }
    return UserData(
      name: "John Doe",
      username: "johndoe",
      email: "john@example.com",
      img: "assets/placeholder.png",
      birthdate: DateTime(2000, 1, 1),
      role: "student",
      id: userId,
      gamesPlayed: [],
      classes: ['class1', 'class2'],
    );
  }
  @override
  Future<void> createAssignment({
    required String title,
    required DateTime dueDate,
    required String turma,
    required String gameId,
  }) async {
    if (_throwErrorOnSave) {
      throw Exception('Failed to save assignment');
    }
  }
}

class MockAuthService extends Mock implements AuthService {
  late String uid;

  MockAuthService({MockFirebaseAuth? firebaseAuth}) {
    uid = firebaseAuth?.currentUser?.uid ?? '';
  }

  @override
  Future<String> getUid() async {
    return uid;
  }

  @override
  Stream<User?> get authStateChanges => Stream.value(MockUser());
}

void main() {
  late Widget testWidget;
  late MockFirebaseAuth testauth;
  setUp(() async {
    testauth = MockFirebaseAuth(mockUser: MockUser(uid: 'test', email: 'john@example.com'), signedIn: true);
    testWidget = MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
            create: (_) => MockAuthService(firebaseAuth: testauth)),
        Provider<DataService>(create: (context) => MockDataService()),
      ],
      child: MaterialApp(
        home: CreateAssignmentPage(gameId: 'game'),
        routes: {
          '/auth_gate': (context) => MockAuthGate(),
        },
      ),
    );
  });

  testWidgets('1. Page loads correctly', (tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    expect(find.text('Create Assignment'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Due Date'), findsOneWidget);
    expect(find.text('Class'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });

  testWidgets('2. User can type into title field', (tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'My Awesome Assignment');
    expect(find.text('My Awesome Assignment'), findsOneWidget);
  });

  testWidgets('3. User can pick a due date', (tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('dueDate')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('15')); // Pick 15th of current month
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // No crash = success
    expect(find.byType(TextField).at(1), findsOneWidget);
  });

  testWidgets('4. Classes load correctly in dropdown', (tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    expect(find.text('class1'), findsWidgets);
    expect(find.text('class2'), findsWidgets);
  });

  testWidgets('5. User can select a class', (tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('class2').last);
    await tester.pumpAndSettle();

    expect(find.text('class2'), findsOneWidget);
  });

  testWidgets('6. Saving works and shows success', (tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Homework');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('class1').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Successfully saved.'), findsOneWidget);
  });

  testWidgets('7. Leaving with unsaved changes shows alert', (tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Unsaved Homework');
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Unsaved Changes'), findsOneWidget);
  });

  testWidgets('8. Leaving without changes does not show alert', (tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // It directly navigates, no alert
    expect(find.text('Unsaved Changes'), findsNothing);
  });

  testWidgets('9. Saving fails and shows error dialog', (tester) async {
    MockDataService mock = MockDataService();
    mock.setThrowErrorOnSave(true);

    testWidget = MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
            create: (_) => MockAuthService(firebaseAuth: testauth)),
        Provider<DataService>(create: (context) => mock),
      ],
      child: MaterialApp(
        home: CreateAssignmentPage(gameId: 'game'),
        routes: {
          '/auth_gate': (context) => AuthGate(),
        },
      ),
    );

    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Error Homework');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('class1').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Error'), findsOneWidget);
    expect(find.text('Error creating assignment.'), findsOneWidget);
  });
}
