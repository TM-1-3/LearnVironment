import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/games_templates/games_initial_screen.dart';
import 'package:learnvironment/teacher/widgets/game_card_teacher.dart';
import 'package:learnvironment/teacher/games_page_teacher.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockAuthService extends AuthService {
  MockAuthService({MockFirebaseAuth? firebaseAuth})
      : super(firebaseAuth: firebaseAuth);

  @override
  Future<String> getUid() async {
    return 'user123';
  }

  @override
  Stream<User?> get authStateChanges => Stream.value(MockUser());
}

class MockDataService extends Mock implements DataService {
  @override
  Future<List<Map<String, dynamic>>> getAllGames() async {
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
      "What is recycling?": "Tip",
      "Why should we save water?": "Tip",
    };

    final games = [
      {
        'logo': 'assets/placeholder.png',
        'name': 'Test Game',
        'tags': ['Strategy'],
        'description': 'description',
        'bibliography': 'Bibliography',
        'template': 'drag',
        'tips' : tips,
        'correctAnswers': correctAnswers,
        'public' : 'true'
      },
      {
        'logo': 'assets/placeholder.png',
        'name': 'Another Game',
        'tags': ['Citizenship'],
        'description': 'description',
        'bibliography': 'Bibliography',
        'template': 'quiz',
        'questionsAndOptions': questionsAndOptions,
        'correctAnswers': correctAnswers,
        'tips' : tips,
        'public' : 'true'
      },
      {
        'logo': 'assets/placeholder.png',
        'name': 'Game 12+',
        'tags': ['Age: 12+', 'Strategy'],
        'description': 'description',
        'bibliography': 'Bibliography',
        'template': 'quiz',
        'questionsAndOptions': questionsAndOptions,
        'correctAnswers': correctAnswers,
        'tips' : tips,
        'public' : 'true'
      },
      {
        'logo': 'assets/placeholder.png',
        'name': 'Game 10+',
        'tags': ['Age: 10+', 'Citizenship'],
        'description': 'description',
        'bibliography': 'Bibliography',
        'template': 'drag',
        'tips' : tips,
        'correctAnswers': correctAnswers,
        'public' : 'true'
      },
    ];

    // Returning the games directly
    print('[Mocked DataService] Returning hardcoded games');
    return List.generate(games.length, (index) {
      final game = games[index];
      return {
        'imagePath': game['logo'],
        'gameTitle': game['name'],
        'tags': game['tags'],
        'gameId': 'mock_game_$index',
      };
    });
  }

  @override
  Future<GameData?> getGameData({required String gameId}) async {
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
      "What is recycling?": "Reusing materials",
      "Why should we save water?": "It helps the earth",
    };

    final data = {
      'logo': 'assets/placeholder.png',
      'name': 'Test Game',
      'tags': ['Strategy'],
      'description': 'description',
      'bibliography': 'Bibliography',
      'template': 'drag',
    };


    final gameData = GameData(
      gameLogo: data['logo'].toString(),
      gameName: data['name'].toString(),
      gameDescription: data['description'].toString(),
      gameBibliography: data['bibliography'].toString(),
      tags: List<String>.from(
          (data['tags'] as List).map((e) => e.toString())),
      gameTemplate: data['template'].toString(),
      documentName: 'mock_game_0',
      questionsAndOptions: questionsAndOptions,
      correctAnswers: correctAnswers,
      tips: tips,
      public: true
    );

    print('[Mocked DataService] Returning mocked game data for gameId: $gameId');
    return gameData;
  }
}


void main() {
  group('TeacherGamesPage Tests', () {
    late MockFirebaseAuth auth;
    late Widget testWidget;

    setUp(() async {
      auth = MockFirebaseAuth(mockUser: MockUser(uid: 'user123', email: 'email@gmail.com'), signedIn: true);

      testWidget = MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>(
                create: (_) => MockAuthService(firebaseAuth: auth)),
            Provider<DataService>(create: (context) => MockDataService()),
          ],
          child: MaterialApp(
            home: GamesPageTeacher(),
        ),
      );
    });

    testWidgets('should display search bar', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();
      expect(find.byKey(Key('search')), findsOneWidget);
    });

    testWidgets('should filter games by search query', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      expect(find.byType(GameCardTeacher), findsNWidgets(2));
      await tester.enterText(find.byKey(Key('search')), 'Test');
      await tester.pumpAndSettle();

      expect(find.text('Test Game'), findsOneWidget);
      expect(find.text('Another Game'), findsNothing);
      expect(find.byType(GameCardTeacher), findsOneWidget);
    });

    testWidgets('should filter games by age tag', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('ageDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('12+').last);
      await tester.pumpAndSettle();

      expect(find.text('Game 12+'), findsOneWidget);
      expect(find.text('Game 10+'), findsNothing);
      expect(find.byType(GameCardTeacher), findsOneWidget);
    });

    testWidgets('should reset age filter when "All Ages" is selected', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('ageDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('12+').last);
      await tester.pumpAndSettle();

      expect(find.byType(GameCardTeacher), findsOneWidget);

      await tester.tap(find.byKey(Key('ageDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All Ages').last);
      await tester.pumpAndSettle();

      expect(
          find.byType(GameCardTeacher), findsNWidgets(2));
    });

    testWidgets('should reset tag filter when "All Tags" is selected', (
        WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('tagDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Strategy').last);
      await tester.pumpAndSettle();

      expect(find.text('Test Game'), findsOneWidget);
      expect(find.byType(GameCardTeacher), findsNWidgets(2));

      await tester.tap(find.byKey(Key('tagDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All Tags').last);
      await tester.pumpAndSettle();

      expect(find.byType(GameCardTeacher), findsNWidgets(2));
    });

    testWidgets('should call load game correctly', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      final gameCardKey = Key('gameCard_mock_game_0');
      expect(find.byKey(gameCardKey), findsOneWidget);
      await tester.tap(find.byKey(gameCardKey));
      await tester.pumpAndSettle();

      expect(find.byType(GamesInitialScreen), findsOneWidget);
    });

    testWidgets('should display no results found message if no games match the filters', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      await tester.enterText(find.byKey(Key('search')), 'Nonexistent');
      await tester.pumpAndSettle();

      expect(find.text('No results found'),
          findsOneWidget); // No games should match
    });
  });
}