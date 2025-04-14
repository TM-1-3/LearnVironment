import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/games_templates/games_initial_screen.dart';
import 'package:learnvironment/games_templates/quiz.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore mockFirestore;
  late GameData gameData;
  late MockUser mockUser;
  late Widget testWidget;

  setUp(() async {
    mockUser = MockUser(uid: 'user123', email: 'email@gmail.com');
    mockAuth = MockFirebaseAuth(mockUser: mockUser);
    mockAuth.signInWithEmailAndPassword(email: 'email@gmail.com', password: 'password');
    mockFirestore = FakeFirebaseFirestore();

    await mockFirestore.collection('users').doc('user123').set(
        {
          'birthdate' : '2000-01-01T00:00:00.000',
          'email' : 'email@gmail.comt',
          'name' : 'L',
          'role' : 'developer',
          'username' : 'Lebi'
        }
    );

    gameData = GameData(
      gameLogo: 'assets/widget.png',
      gameName: 'Test Game',
      gameDescription: 'Test Description',
      gameBibliography: 'Test Bibliography',
      tags: ['tag1', 'tag2'],
      gameTemplate: 'quiz',
      questionsAndOptions: {},
      correctAnswers: {},
      documentName: 'doc',
    );

    testWidget = MaterialApp(
      home: GamesInitialScreen(
        gameData: gameData,
      ),
    );
  });

  testWidgets('Renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // Verify that the game name is displayed
    expect(find.text('Test Game'), findsExactly(2));

    // Verify the "Play" button is present
    expect(find.text('Play'), findsOneWidget);
  });

  test('updateUserGamesPlayed updates Firestore correctly with game at front', () async {
    final screen = GamesInitialScreen(
      gameData: gameData,
    );

    // Simulate playing two games
    await screen.updateUserGamesPlayed('user123', 'game123');
    await screen.updateUserGamesPlayed('user123', 'game456');

    // Re-play 'game123', it should now be at the front
    await screen.updateUserGamesPlayed('user123', 'game123');

    DocumentSnapshot userDoc = await mockFirestore.collection('users').doc('user123').get();
    List<dynamic> gamesPlayed = userDoc['gamesPlayed'];

    // Check the order and contents
    expect(gamesPlayed.length, 2);
    expect(gamesPlayed[0], 'game123');
    expect(gamesPlayed[1], 'game456');
  });

  testWidgets('Play button navigates to correct screen based on game template', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    await tester.ensureVisible(find.text('Play'));
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    expect(find.byType(Quiz), findsOneWidget);
  });

  testWidgets('Play button shows error message when gameData is corrupted', (WidgetTester tester) async {
    // Create game data with invalid template
    final corruptedGameData = GameData(
      gameLogo: 'assets/widget.png',
      gameName: 'Corrupted Game',
      gameDescription: 'Corrupted Description',
      gameBibliography: 'Corrupted Bibliography',
      tags: ['corrupted'],
      gameTemplate: 'unknown', //Invalid template to trigger error
      questionsAndOptions: {},
      correctAnswers: {},
      documentName: 'doc',
    );

    // Build the widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: GamesInitialScreen(
          gameData: corruptedGameData,
        ),
      ),
    );

    // Tap on the "Play" button
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    // Verify that the error snackbar is shown
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Error Game Data Corrupted.'), findsOneWidget);
  });
}
