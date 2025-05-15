import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/main_pages/games_page.dart';
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
      },
      {
        'logo': 'assets/placeholder.png',
        'name': 'Game 10+',
        'tags': ['Age: 10+', 'Citizenship'],
        'description': 'description',
        'bibliography': 'Bibliography',
        'template': 'drag',
        'tips' : tips,
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
  group('GamesPage Tests', () {
    late MockFirebaseAuth auth;
    late Widget testWidget;

    setUp(() async {
      auth = MockFirebaseAuth(mockUser: MockUser(uid: 'user123', email: 'email@gmail.com'), signedIn: true);

      testWidget = MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>(create: (_) => MockAuthService(firebaseAuth: auth)),
            Provider<DataService>(create: (context) => MockDataService()),
          ],
          child: MaterialApp(
            home: GamesPage(),
        ),
      );
    });

    testWidgets('should display search bar', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();
      expect(find.byKey(Key('search')), findsOneWidget);
    });
  });
}