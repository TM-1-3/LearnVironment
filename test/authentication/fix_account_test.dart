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
  Stream<User?> get authStateChanges => Stream.value(MockUser());
}

class MockDataService extends Mock implements DataService {
  MockDataService();

  @override
  Future<bool> checkIfUsernameAlreadyExists(String username) async {
    if (username=='testuser'){
      return true;
    }
    return false;
  }

  @override
  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String username,
    required String email,
    required String role,
    required String birthDate,
    required String img}) async {

  }
}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockAuthService authService;
  late Widget testWidget;

  setUp(() {
    mockAuth = MockFirebaseAuth(
      mockUser: MockUser(
        email: 'test@example.com',
        displayName: 'Test User',
      ),
      signedIn: true
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
    await tester.ensureVisible(registerButton);
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
    await tester.ensureVisible(find.byType(DropdownButton<String>));
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pump();
    await tester.tap(find.text('developer').last);
    await tester.pump();

    // Find the birthdate TextField
    final dateField = find.byKey(Key("birthDate"));
    await tester.ensureVisible(dateField);
    await tester.pumpAndSettle();
    await tester.tap(dateField);
    await tester.pumpAndSettle();
    expect(find.byType(CalendarDatePicker), findsOneWidget);

    //Select Year
    await tester.ensureVisible(find.text('January 2000'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('January 2000'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('1993'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1993'));
    await tester.pumpAndSettle();

    //Select Date
    await tester.ensureVisible(find.text('20'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();

    //Enter Date
    await tester.ensureVisible(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Verify that the Register button is now enabled
    final registerButton = find.byType(ElevatedButton);
    expect(tester.widget<ElevatedButton>(registerButton).enabled, true);
  });

  testWidgets('should call updateUserProfile when register button is pressed', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // Fill out the required fields
    await tester.enterText(find.byType(TextField).at(0), 'John Doe');
    await tester.enterText(find.byType(TextField).at(1), 'https://www.pixartprinting.it/blog/wp-content/uploads/2021/06/1_Mona_Lisa_300ppi.jpg');
    await tester.enterText(find.byType(TextField).at(2), '2023-05-10');
    await tester.enterText(find.byType(TextField).at(3), 'john_doe');
    await tester.enterText(find.byType(TextField).at(4), 'john@example.com');

    // Select account type
    await tester.ensureVisible(find.byType(DropdownButton<String>));
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pump();
    await tester.tap(find.text('developer').last);
    await tester.pump();

    // Find the birthdate TextField
    final dateField = find.byKey(Key("birthDate"));
    await tester.ensureVisible(dateField);
    await tester.pumpAndSettle();
    await tester.tap(dateField);
    await tester.pumpAndSettle();
    expect(find.byType(CalendarDatePicker), findsOneWidget);

    //Select Year
    await tester.ensureVisible(find.text('January 2000'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('January 2000'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('1993'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1993'));
    await tester.pumpAndSettle();

    //Select Date
    await tester.ensureVisible(find.text('20'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();

    //Enter Date
    await tester.ensureVisible(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Press the Register button
    await tester.ensureVisible(find.byType(ElevatedButton));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.byType(MockAuthGate), findsOneWidget);
  });
}
