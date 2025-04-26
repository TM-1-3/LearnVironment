import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/authentication/auth_gate.dart';
import 'package:learnvironment/teacher/create_subject_page.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/data/subject_data.dart';
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

// Mock classes
class MockAuthService extends Mock implements AuthService {
  late bool _loggedIn;
  late String uid;

  @override
  bool get loggedIn => _loggedIn;

  @override
  set loggedIn(bool value) {
    _loggedIn = value;
  }

  MockAuthService({MockFirebaseAuth? firebaseAuth}) {
    loggedIn = firebaseAuth?.currentUser != null;
    uid = firebaseAuth?.currentUser?.uid ?? '';
  }

  @override

  Future<String> getUid() async {
    return uid;
  }

  @override
  Stream<User?> get authStateChanges => Stream.value(MockUser());
}
class MockDataService extends Mock implements DataService {
  bool _throwErrorOnSave = false;
  void setThrowErrorOnSave(bool value) {
    _throwErrorOnSave = value;
  }
  @override
  Future<void> addSubject({required SubjectData subject}) async {
    if (_throwErrorOnSave) {
      throw Exception('Failed to create Subject');
    }
  }
}

void main() {
  late MockAuthService mockAuthService;
  late MockDataService mockDataService;
  late Widget testWidget;

  setUp(() {
    mockAuthService = MockAuthService(firebaseAuth: MockFirebaseAuth(mockUser: MockUser(uid: 'test', email: 'john@example.com'), signedIn: true));
    mockDataService = MockDataService();
    testWidget = MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => mockAuthService,
        ),
        Provider<DataService>(create: (_) => mockDataService),
      ],
      child: MaterialApp(
        home: CreateSubjectPage(),
        routes: {
          '/auth_gate': (context) => MockAuthGate(),
        },),
    );
  });

  group('CreateSubjectPage Tests', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(testWidget);
      
      expect(find.text('Subject Name'), findsOneWidget);
      expect(find.text('Logo URL'), findsOneWidget);
      expect(find.text('Create Subject'), findsExactly(2));
    });

    testWidgets('shows validation errors when fields are empty', (tester) async {
      await tester.pumpWidget(testWidget);

      await tester.tap(find.byKey(Key("button")));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a subject name'), findsOneWidget);
    });

    testWidgets('calls _createSubject successfully', (tester) async {
      await tester.pumpWidget(testWidget);

      // Enter valid data
      await tester.enterText(find.byType(TextFormField).at(0), 'Math');
      await tester.enterText(find.byType(TextFormField).at(1), 'https://example.com/image.png');

      await tester.tap(find.byKey(Key("button")));
      await tester.pump(); // start async work
      await tester.pump(const Duration(seconds: 1)); // finish async work

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows error snackbar on failure', (tester) async {
      mockDataService.setThrowErrorOnSave(true);
      testWidget = MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(
            create: (_) => mockAuthService,
          ),
          Provider<DataService>(create: (_) => mockDataService),
        ],
        child: MaterialApp(
          home: CreateSubjectPage(),
          routes: {
            '/auth_gate': (context) => MockAuthGate(),
          },),
      );
      await tester.pumpWidget(testWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'Biology');
      await tester.enterText(find.byType(TextFormField).at(1), 'https://example.com/logo.png');

      await tester.tap(find.byKey(Key("button")));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.textContaining('Failed to create subject'), findsOneWidget);
    });
  });
}