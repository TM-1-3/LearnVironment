import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/authentication/auth_gate.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/developer/my_games.dart';
import 'package:learnvironment/games_templates/games_initial_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/firebase/auth_service.dart';
import 'package:learnvironment/services/cache/user_cache_service.dart';
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
  Future<List<Map<String, dynamic>>> getMyGames({required String uid}) async {
    if (uid == "error") {
      return [
        {
          'gameTitle': 'Strategy Fun',
          'tags': ['Strategy', 'Age: 12+'],
          'gameId': 'gx',
          'imagePath': 'assets/placeholder.png',
          'public' : true,
        },
      ];
    }
      return [
        {
          'gameTitle': 'Strategy Fun',
          'tags': ['Strategy', 'Age: 12+'],
          'gameId': 'g1',
          'imagePath': 'assets/placeholder.png',
          'public' : true,
        },
      ];
  }


  @override
  Future<GameData?> getGameData({required String gameId}) async {
    if (gameId == "gx") {
      throw Exception('Failed to load');
    }

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
class MockUserCacheService extends Mock implements UserCacheService {
  @override
  Future<void> clearUserCache() async {
    // Do nothing
  }
}


void main() {
  late MockDataService mockDataService;
  late MockAuthService mockAuthService;
  late MockUserCacheService mockUserCacheService;
  late MockFirebaseAuth mockFirebaseAuth;
  late Widget testWidget;

  setUp(() {
    mockDataService = MockDataService();
    mockUserCacheService = MockUserCacheService();
  });

  testWidgets('navigates to game screen on game card tap', (WidgetTester tester) async {
    mockFirebaseAuth = MockFirebaseAuth(mockUser: MockUser(uid: '3', email: 'email@gmail.com'), signedIn: true);
    mockAuthService = MockAuthService(firebaseAuth: mockFirebaseAuth);

    testWidget = MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => mockAuthService,
        ),
        Provider<DataService>(create: (_) => mockDataService),
        Provider<UserCacheService>(create: (_) => mockUserCacheService),
      ],
      child: const MaterialApp(
        home: MyGamesPage(),
      ),
    );

    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    final gameCardKey = Key('gameCard_g1');
    expect(find.byKey(gameCardKey), findsOneWidget);
    await tester.tap(find.byKey(gameCardKey));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    expect(find.byType(GamesInitialScreen), findsOneWidget);
  });
}
