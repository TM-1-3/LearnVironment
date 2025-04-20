import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/games_templates/games_initial_screen.dart';
import 'package:learnvironment/games_templates/quiz.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:learnvironment/services/firestore_service.dart';
import 'package:learnvironment/services/game_cache_service.dart';
import 'package:learnvironment/services/user_cache_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore mockFirestore;
  late GameData gameData;
  late MockUser mockUser;
  late Widget testWidget;

  setUp(() async {
    mockUser = MockUser(uid: 'user123', email: 'email@gmail.com');
    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    mockFirestore = FakeFirebaseFirestore();

    await mockFirestore.collection('users').doc('user123').set({
      'birthdate': '2000-01-01T00:00:00.000',
      'email': 'email@gmail.com',
      'name': 'Lebi',
      'role': 'developer',
      'username': 'Lebi',
      'gamesPlayed': [],
    });

    SharedPreferences.setMockInitialValues({
      'id': 'user123',
      'username': 'Lebi',
      'email': 'email@gmail.com',
      'name': 'Lebi',
      'role': 'developer',
      'birthdate': '2000-01-01T00:00:00.000',
      'gamesPlayed': '',
    });

    // Populate Firestore with game data
    final Map<String, List<String>> questionsAndOptions = {
      "What is recycling?": [
        "Reusing materials",
        "Throwing trash",
        "Saving money",
        "Buying new things"
      ],
      "Why should we save water?": [
        "It helps the earth",
        "Water is unlimited",
        "For fun",
        "It doesn't matter"
      ],
    };

    final Map<String, String> correctAnswers = {
      "What is recycling?": "Reusing materials",
      "Why should we save water?": "It helps the earth",
    };

    final Map<String, String> tips = {
      "What is recycling?": "Tip1",
      "Why should we save water?": "Tip2",
    };

    await mockFirestore.collection('games').doc('game1').set({
      'logo': 'assets/widget.png',
      'name': 'Test Game',
      'description': 'Test Description',
      'bibliography': 'Test Bibliography',
      'tags': ['action', 'adventure'],
      'template': 'quiz',
      'questionsAndOptions': questionsAndOptions,
      'correctAnswers': correctAnswers,
      'tips': tips
    });

    // Set up GameData instance
    gameData = GameData(
      gameLogo: 'assets/widget.png',
      gameName: 'Test Game',
      gameDescription: 'Test Description',
      gameBibliography: 'Test Bibliography',
      tags: ['action', 'adventure'],
      gameTemplate: 'quiz',
      questionsAndOptions: questionsAndOptions,
      correctAnswers: correctAnswers,
      documentName: 'game1',
      tips: tips,
    );

    // Set up the widget tree for testing
    testWidget = MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(create: (_) => AuthService(firebaseAuth: mockAuth)),
          Provider<FirestoreService>(create: (_) => FirestoreService(firestore: mockFirestore)),
          Provider<UserCacheService>(create: (_) => UserCacheService()),
          Provider<GameCacheService>(create: (_) => GameCacheService()),
          Provider<DataService>(create: (context) => DataService(context)),
        ],
        child: GamesInitialScreen(gameData: gameData),
      ),
    );
  });

  testWidgets('Renders game data correctly', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();
    expect(find.text('Test Game'), findsExactly(2));
    await tester.tap(find.text('Description'));
    await tester.pumpAndSettle();
    expect(find.text('Test Description'), findsOneWidget);
    await tester.ensureVisible(find.text('Bibliography'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bibliography'));
    await tester.pumpAndSettle();
    expect(find.text('Test Bibliography'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
  });

  testWidgets('Play button navigates to Quiz screen', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    expect(find.byType(Quiz), findsOneWidget);
  });

  testWidgets('Error message displays for corrupted game data', (WidgetTester tester) async {
    final corruptedGameData = GameData(
      gameLogo: 'assets/widget.png',
      gameName: 'Corrupted Game',
      gameDescription: 'Corrupted Description',
      gameBibliography: 'Corrupted Bibliography',
      tags: [],
      gameTemplate: 'unknown',
      questionsAndOptions: {},
      correctAnswers: {},
      documentName: 'corrupted_game',
      tips: {},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>(create: (_) => AuthService(firebaseAuth: mockAuth)),
            Provider<FirestoreService>(create: (_) => FirestoreService(firestore: mockFirestore)),
            Provider<UserCacheService>(create: (_) => UserCacheService()),
            Provider<GameCacheService>(create: (_) => GameCacheService()),
            Provider<DataService>(create: (context) => DataService(context)),
          ],
          child: GamesInitialScreen(gameData: corruptedGameData),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    // Verify error message
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Error Game Data Corrupted.'), findsOneWidget);
  });
}
