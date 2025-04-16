import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/games_templates/games_initial_screen.dart';
import 'package:learnvironment/main_pages/widgets/game_card.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/student/student_stats.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockAuthService extends AuthService {
  late String uid;
  MockAuthService({MockFirebaseAuth? firebaseAuth})
      : super(firebaseAuth: firebaseAuth) {
    uid = firebaseAuth?.currentUser?.uid ?? '';}

  @override
  Future<String> getUid() async {
    return uid;
  }

  @override
  Stream<User?> get authStateChanges => Stream.value(MockUser());
}

class MockDataService extends Mock implements DataService {
  @override
  Future<void> updateUserGamesPlayed(String userId, String gameId) async {
    //do nothing
  }

  @override
  Future<List<Map<String, dynamic>>> getPlayedGames(String userId) async {
    if (userId == "user123") {
      try {
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

        final games = [
          {
            'logo': 'assets/placeholder.png',
            'name': 'Test Game',
            'tags': ['Strategy'],
            'description': 'description',
            'bibliography': 'Bibliography',
            'template': 'drag',
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
          },
          {
            'logo': 'assets/placeholder.png',
            'name': 'Game 10+',
            'tags': ['Age: 10+', 'Citizenship'],
            'description': 'description',
            'bibliography': 'Bibliography',
            'template': 'drag',
          },
        ];

        // Returning the games directly
        print('[Mocked DataService] Returning hardcoded games');
        return games.map((game) {
          return {
            'imagePath': game['logo'],
            'gameTitle': game['name'],
            'tags': game['tags'],
            'gameId': 'mock_game_id', // You can adjust this ID if needed
          };
        }).toList();
      } catch (e, stack) {
        print('[DataService] Error in getPlayedGames: $e\n$stack');
        return [];
      }
    } else {
      Exception("No games Played");
      return [];
    }
  }

  @override
  Future<GameData?> getGameData(String gameId) async {
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

    final data = {
      'logo': 'assets/placeholder.png',
      'name': 'Test Game',
      'tags': ['Strategy'],
      'description': 'description',
      'bibliography': 'Bibliography',
      'template': 'drag',
    };

    final tips = {
      "What is recycling?" : "This is a tip",
      "Why should we save water?": "Another tip",
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
    );

    print('[Mocked DataService] Returning mocked game data for gameId: $gameId');
    return gameData;
  }
}

void main() {
  group('StudentStatsPage Tests', () {
    late Widget testWidget;
    late MockFirebaseAuth auth;
    setUp(() async {
      auth = MockFirebaseAuth(mockUser: MockUser(uid: 'user123', email: 'email@gmail.com'), signedIn: true);

      testWidget =MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>(create: (_) => MockAuthService(firebaseAuth: auth)),
            Provider<DataService>(create: (context) => MockDataService()),
          ],
          child: MaterialApp(
              home: StudentStatsPage()
        ),
      );
    });

    testWidgets('should display game cards when games are loaded', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      expect(find.byType(GameCard), findsNWidgets(2));
    });

    testWidgets('should display message if no games are played', (WidgetTester tester) async {
      auth = MockFirebaseAuth(mockUser: MockUser(uid: '', email: 'email@gmail.com'), signedIn: true);

      testWidget =MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(create: (_) => MockAuthService(firebaseAuth: auth)),
          Provider<DataService>(create: (context) => MockDataService()),
        ],
        child: MaterialApp(
            home: StudentStatsPage()
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      expect(find.text('No games have been played yet!'), findsOneWidget);
    });

    testWidgets('should navigate to game details when game card is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(find.byType(GamesInitialScreen), findsOneWidget);
    });
  });
}
