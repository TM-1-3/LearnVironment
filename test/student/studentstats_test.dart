import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/games_templates/games_initial_screen.dart';
import 'package:learnvironment/main_pages/widgets/game_card.dart';
import 'package:learnvironment/services/firebase/auth_service.dart';
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
  Future<void> updateUserGamesPlayed({required String userId, required String gameId}) async {
    //do nothing
  }

  @override
  Future<List<Map<String, dynamic>>> getWeekGameResults({required String studentId}) async {
    if (studentId == "user123") {
      // Provide some mock weekly data
      return [
        {
          'date': DateTime.now().subtract(const Duration(days: 6)),
          'correctCount': 5,
          'wrongCount': 2,
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 5)),
          'correctCount': 3,
          'wrongCount': 4,
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 4)),
          'correctCount': 6,
          'wrongCount': 1,
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 3)),
          'correctCount': 4,
          'wrongCount': 3,
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 2)),
          'correctCount': 7,
          'wrongCount': 0,
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'correctCount': 5,
          'wrongCount': 1,
        },
        {
          'date': DateTime.now(),
          'correctCount': 8,
          'wrongCount': 2,
        },
      ];
    } else {
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPlayedGames({required String userId}) async {
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
      public: true
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

      expect(find.byType(GameCard), findsNWidgets(4));
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
      await tester.ensureVisible(find.byType(GestureDetector).first);
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(find.byType(GamesInitialScreen), findsOneWidget);
    });

    testWidgets('shows weekly performance bar chart with correct weekday labels', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Verify the title of weekly performance exists
      expect(find.text('Your Weekly Performance'), findsOneWidget);

      // Check for the presence of some weekday labels in the chart
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);

      // Check the legend texts exist
      expect(find.text("✅ Correct answers"), findsOneWidget);
      expect(find.text("❌ Wrong answers"), findsOneWidget);

      // Since weekData is mocked with entries, the chart bars should be visible
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('displays no data message when weekData is empty', (WidgetTester tester) async {
      // Override the DataService provider with empty week data
      testWidget = MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(create: (_) => MockAuthService(firebaseAuth: auth)),
          Provider<DataService>(create: (_) => MockDataServiceEmptyWeekData()),
        ],
        child: MaterialApp(home: StudentStatsPage()),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      expect(find.text('No weekly data available.'), findsOneWidget);
    });

    testWidgets('pull to refresh reloads games and week data', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Drag down to trigger RefreshIndicator
      final listFinder = find.byType(RefreshIndicator);
      expect(listFinder, findsOneWidget);

      await tester.drag(listFinder, const Offset(0, 300));
      await tester.pump(); // start the indicator
      await tester.pump(const Duration(seconds: 1)); // finish the indicator

      // After refresh, games and week data should still be displayed
      expect(find.byType(GameCard), findsWidgets);
      expect(find.byType(BarChart), findsOneWidget);
    });
  });
}

/// MockDataService providing weekData for testing the chart
class MockDataServiceWithWeekData extends Mock implements DataService {
  @override
  Future<List<Map<String, dynamic>>> getPlayedGames({required String userId}) async {
    return [
      {
        'imagePath': 'assets/placeholder.png',
        'gameTitle': 'Test Game 1',
        'tags': ['Strategy'],
        'gameId': 'game1',
      },
      {
        'imagePath': 'assets/placeholder.png',
        'gameTitle': 'Test Game 2',
        'tags': ['Quiz'],
        'gameId': 'game2',
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getWeekGameResults({required String studentId}) async {
    // Returning mock week data with correctCount, wrongCount and date
    return [
      {
        'correctCount': 5,
        'wrongCount': 2,
        'date': DateTime.now().subtract(Duration(days: 6)), // approx Monday
      },
      {
        'correctCount': 3,
        'wrongCount': 4,
        'date': DateTime.now().subtract(Duration(days: 5)), // approx Tuesday
      },
      // add more if needed
    ];
  }
}

/// MockDataService with empty week data to test empty chart message
class MockDataServiceEmptyWeekData extends Mock implements DataService {
  @override
  Future<List<Map<String, dynamic>>> getPlayedGames({required String userId}) async {
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getWeekGameResults({required String studentId}) async {
    return [];
  }
}