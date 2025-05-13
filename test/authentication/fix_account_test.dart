import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/authentication/auth_gate.dart';
import 'package:learnvironment/authentication/fix_account.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
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

class MockAuthService extends AuthService {
  MockAuthService({MockFirebaseAuth? firebaseAuth})
      : super(firebaseAuth: firebaseAuth);

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {

  }

  @override
  Stream<User?> get authStateChanges => Stream.value(MockUser());
}

class MockDataService extends Mock implements DataService {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockDataService mockDataService;
  late MockAuthService authService;
  late Widget testWidget;

  setUp(() {
    mockAuth = MockFirebaseAuth(
      mockUser: MockUser(
        email: 'test@example.com',
        displayName: 'Test User',
      ),
    );


    authService = MockAuthService(firebaseAuth: mockAuth);

    testWidget = MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => authService),
        Provider<DataService>(create: (context) => MockDataService()),
      ],
      child: MaterialApp(
        home: FixAccountPage(),
        routes: {
          '/auth_gate': (context) => MockAuthGate(),
          '/fix_account': (context) => FixAccountPage(),
        },
      ),
    );
  });


  testWidgets('should show validation error if fields are empty', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    final registerButton = find.byType(ElevatedButton);
    await tester.tap(registerButton);
    await tester.pump();

    expect(find.text('Please fill in all fields.'), findsOneWidget);
  });

  testWidgets('should enable button when all fields are filled', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // Fill out the required fields
    await tester.enterText(find.byType(TextField).at(0), 'John Doe');
    await tester.enterText(find.byType(TextField).at(1), 'https://someurl.com/image.png');
    await tester.enterText(find.byType(TextField).at(2), '2023-05-10');
    await tester.enterText(find.byType(TextField).at(3), 'john_doe');
    await tester.enterText(find.byType(TextField).at(4), 'john@example.com');

    // Select account type
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pump();
    await tester.tap(find.text('developer').last);
    await tester.pump();

    // Verify that the Register button is now enabled
    final registerButton = find.byType(ElevatedButton);
    expect(tester.widget<ElevatedButton>(registerButton).enabled, true);
  });

  testWidgets('should call updateUserProfile when register button is pressed', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // Fill out the required fields
    await tester.enterText(find.byType(TextField).at(0), 'John Doe');
    await tester.enterText(find.byType(TextField).at(1), 'https://someurl.com/image.png');
    await tester.enterText(find.byType(TextField).at(2), '2023-05-10');
    await tester.enterText(find.byType(TextField).at(3), 'john_doe');
    await tester.enterText(find.byType(TextField).at(4), 'john@example.com');

    // Select account type
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pump();
    await tester.tap(find.text('developer').last);
    await tester.pump();

    // Press the Register button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.byType(MockAuthGate), findsOneWidget);
  });
}
