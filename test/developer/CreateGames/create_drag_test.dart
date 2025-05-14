import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/authentication/auth_gate.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/developer/CreateGames/create_drag.dart';
import 'package:learnvironment/developer/new_game.dart';
import 'package:mockito/mockito.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:provider/provider.dart';

class MockDataService extends Mock implements DataService {
  @override
  Future<void> createGame({required String uid, required GameData game}) async {
    print("created game");
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
      ],
      child: MaterialApp(
        home: CreateDragPage(),
        routes: {
          '/auth_gate': (context) => MockAuthGate(),
        },
      ),
    );
  });

  testWidgets('CreateDragPage renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    expect(find.text('Create Drag Game'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(12));
    expect(find.byType(ElevatedButton), findsExactly(2));
  });

  testWidgets('Form validation shows error when fields are empty', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    await tester.tap(find.text("Trash Objects"));

    final submit = find.byKey(Key("submit"));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();

    expect(find.text('Please fill in all fields for all Objects'), findsOneWidget);
  });

  testWidgets('Trash object image URL validation fails with invalid URL', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    //Fill all text fields
    await tester.enterText(find.byType(TextFormField).at(0), 'https://example.com/logo.png');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(1), 'Game Title');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(2), 'Game Description');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(3), 'Game Bibliography');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(4), 'invalid image');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(5), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(6), 'https://example.com/logo.png');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(7), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(8), 'https://example.com/logo.png');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(9), 'tip');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(10), 'https://example.com/logo.png');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(11), 'tip');
    await tester.pumpAndSettle();

    //Select all options from dropdown
    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(1));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yellow bin').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(2));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yellow bin').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(3));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(3));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yellow bin').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>).at(4));
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(4));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yellow bin').last);
    await tester.pumpAndSettle();

    //Submit
    final submit = find.byKey(Key("submit"));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();

    expect(find.text('Please use a valid image URL in Object 0'), findsOneWidget);
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

    final dragCard = find.text('Create a drag game');
    expect(dragCard, findsOneWidget);

    await tester.tap(dragCard);
    await tester.pumpAndSettle();
    expect(find.byType(CreateDragPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Unsaved Changes'), findsOneWidget);
    expect(find.text('You have unsaved changes. Do you want to leave without saving?'), findsOneWidget);
  });
}
