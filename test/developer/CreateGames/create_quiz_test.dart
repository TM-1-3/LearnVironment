import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/authentication/auth_gate.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/developer/CreateGames/create_quiz.dart';
import 'package:learnvironment/developer/new_game.dart';
import 'package:learnvironment/services/image_validator_service.dart';
import 'package:mockito/mockito.dart';
import 'package:learnvironment/services/firebase/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:provider/provider.dart';

class MockDataService extends Mock implements DataService {
  @override
  Future<void> createGame({required String uid, required GameData game}) async {
    if (game.gameName == "fail") {
      throw Exception("Failed");
    }
  }
}

class MockImageValidatorService extends Mock implements ImageValidatorService {
  @override
  Future<bool> validateImage(String imageUrl) async {
    if (imageUrl == 'invalid image') {
      return false;
    }
    return true;
  }
}

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
  Future<String> getUid() async {
    return "string";
  }
}

void main() {
  late Widget testWidget;
  late AuthService authService;

  setUp(() {
    authService = MockAuthService(
        firebaseAuth: MockFirebaseAuth(
          mockUser: MockUser(
            email: 'test@example.com',
            displayName: 'Test User',
          ),
          signedIn: true
        )
    );
    testWidget = MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => authService),
        Provider<DataService>(create: (context) => MockDataService()),
        Provider<ImageValidatorService>(create: (_) => MockImageValidatorService()),
      ],
      child: MaterialApp(
        home: CreateQuizPage(),
        routes: {
          '/auth_gate': (context) => MockAuthGate(),
        },
      ),
    );
  });

  testWidgets('CreateQuizPage renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    expect(find.text('Create Quiz Game'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(34));
    expect(find.byType(ElevatedButton), findsExactly(2));
  });

  testWidgets('Form validation shows error when fields are empty', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    await tester.tap(find.text("Questions Objects"));

    final submit = find.byKey(Key("submit"));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();

    expect(find.text('Please fill in all fields for all Objects'), findsOneWidget);
  });

  testWidgets('Invalid logo image fails', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    //Fill all text fields
    await tester.enterText(find.byType(TextFormField).at(0), 'invalid image');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(1), 'Game Title');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(2), 'Game Description');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(3), 'Game Bibliography');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(4), 'Question 1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(5), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(6), 'opt1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(7), 'opt2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(8), 'opt3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(9), 'opt4');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(10), 'Question 2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(11), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(12), 'opt1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(13), 'opt2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(14), 'opt3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(15), 'opt4');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(16), 'Question 3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(17), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(18), 'opt1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(19), 'opt2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(20), 'opt3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(21), 'opt4');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(22), 'Question 4');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(23), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(24), 'opt1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(25), 'opt2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(26), 'opt3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(27), 'opt4');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(28), 'Question 5');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(29), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(30), 'opt1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(31), 'opt2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(32), 'opt3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(33), 'opt4');
    await tester.pumpAndSettle();

    //Select all options from dropdown
    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(1));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(2));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(3));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(3));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(4));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(4));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(5));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(5));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1').last);
    await tester.pumpAndSettle();

    //Submit
    final submit = find.byKey(Key("submit"));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();

    expect(find.text('Please use a valid image URL for the Logo'), findsOneWidget);
  });

  testWidgets('Repeated Questions fail', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    //Fill all text fields
    await tester.enterText(find.byType(TextFormField).at(0), 'image.png');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(1), 'Game Title');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(2), 'Game Description');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(3), 'Game Bibliography');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(4), 'Question 1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(5), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(6), 'opt1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(7), 'opt2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(8), 'opt3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(9), 'opt4');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(10), 'Question 1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(11), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(12), 'opt1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(13), 'opt2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(14), 'opt3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(15), 'opt4');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(16), 'Question 3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(17), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(18), 'opt1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(19), 'opt2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(20), 'opt3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(21), 'opt4');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(22), 'Question 4');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(23), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(24), 'opt1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(25), 'opt2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(26), 'opt3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(27), 'opt4');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(28), 'Question 5');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(29), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(30), 'opt1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(31), 'opt2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(32), 'opt3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(33), 'opt4');
    await tester.pumpAndSettle();

    //Select all options from dropdown
    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(1));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(2));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(3));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(3));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(4));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(4));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(5));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(5));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1').last);
    await tester.pumpAndSettle();

    //Submit
    final submit = find.byKey(Key("submit"));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();

    expect(find.text('Please use a unique question in Object 2'), findsOneWidget);
  });

  testWidgets('Handles exceptions gracefully', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    //Fill all text fields
    await tester.enterText(find.byType(TextFormField).at(0), 'image.png');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(1), 'fail');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(2), 'Game Description');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(3), 'Game Bibliography');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(4), 'Question 1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(5), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(6), 'opt1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(7), 'opt2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(8), 'opt3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(9), 'opt4');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(10), 'Question 2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(11), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(12), 'opt1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(13), 'opt2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(14), 'opt3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(15), 'opt4');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(16), 'Question 3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(17), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(18), 'opt1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(19), 'opt2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(20), 'opt3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(21), 'opt4');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(22), 'Question 4');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(23), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(24), 'opt1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(25), 'opt2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(26), 'opt3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(27), 'opt4');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(28), 'Question 5');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(29), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(30), 'opt1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(31), 'opt2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(32), 'opt3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(33), 'opt4');
    await tester.pumpAndSettle();

    //Select all options from dropdown
    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(1));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(2));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(3));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(3));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(4));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(4));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(5));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(5));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1').last);
    await tester.pumpAndSettle();

    //Submit
    final submit = find.byKey(Key("submit"));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();

    expect(find.text('An error occurred. Please try again.'), findsOneWidget);
  });

  testWidgets('Creates a game successfully', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    //Fill all text fields
    await tester.enterText(find.byType(TextFormField).at(0), 'image.png');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(1), 'Name');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(2), 'Game Description');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(3), 'Game Bibliography');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(4), 'Question 1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(5), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(6), 'opt1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(7), 'opt2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(8), 'opt3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(9), 'opt4');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(10), 'Question 2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(11), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(12), 'opt1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(13), 'opt2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(14), 'opt3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(15), 'opt4');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(16), 'Question 3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(17), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(18), 'opt1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(19), 'opt2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(20), 'opt3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(21), 'opt4');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(22), 'Question 4');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(23), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(24), 'opt1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(25), 'opt2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(26), 'opt3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(27), 'opt4');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(28), 'Question 5');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(29), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(30), 'opt1');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(31), 'opt2');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(32), 'opt3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(33), 'opt4');
    await tester.pumpAndSettle();

    //Select all options from dropdown
    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(1));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(2));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(3));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(3));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(4));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(4));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(5));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(5));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1').last);
    await tester.pumpAndSettle();

    //Submit
    final submit = find.byKey(Key("submit"));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();

    expect(find.text('Game Created with success'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(MockAuthGate), findsOneWidget);
  });

  testWidgets('Navigating away shows confirmation dialog when there are unsaved changes', (WidgetTester tester) async {
    testWidget = MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => authService),
        Provider<DataService>(create: (context) => MockDataService()),
      ],
      child: MaterialApp(
        home: NewGamePage(),
        routes: {
          '/auth_gate': (context) => MockAuthGate(),
        },
      ),
    );
    await tester.pumpWidget(testWidget);

    final dragCard = find.text('Create a quiz game');
    expect(dragCard, findsOneWidget);

    await tester.tap(dragCard);
    await tester.pumpAndSettle();
    expect(find.byType(CreateQuizPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Unsaved Changes'), findsOneWidget);
    expect(find.text('You have unsaved changes. Do you want to leave without saving?'), findsOneWidget);
  });
}
