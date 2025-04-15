import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/games_templates/games_initial_screen.dart';
import 'package:learnvironment/main_pages/games_page.dart';
import 'package:learnvironment/main_pages/widgets/game_card.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/firestore_service.dart';
import 'package:learnvironment/services/game_cache_service.dart';
import 'package:learnvironment/services/user_cache_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GamesPage Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth auth;
    late Widget testWidget;
    late GameCacheService gamecache;

    setUp(() async {
      auth = MockFirebaseAuth(mockUser: MockUser(uid: 'user123', email: 'email@gmail.com'), signedIn: true);
      fakeFirestore = FakeFirebaseFirestore();

      await fakeFirestore.collection('users').doc('user123').set({
        'birthdate': '2000-01-01T00:00:00.000',
        'email': 'email@gmail.com',
        'name': 'Lebi',
        'role': 'developer',
        'username': 'Lebi',
        'gamesPlayed': [],
      });

      SharedPreferences.setMockInitialValues({
        // User data
        'id': 'user123',
        'username': 'Lebi',
        'email': 'email@gmail.com',
        'name': 'Lebi',
        'role': 'developer',
        'birthdate': '2000-01-01T00:00:00.000',
        'gamesPlayed': '[]',

        'game_game_0': {
          'gameLogo': 'assets/placeholder.png',
          'gameName': 'Test Game',
          'gameDescription': 'description',
          'gameBibliography': 'Bibliography',
          'gameTemplate': 'drag',
          'documentName': 'game_0'
        },

        'game_game_1': {
          'gameLogo': 'assets/placeholder.png',
          'gameName': 'Another Game',
          'gameDescription': 'description',
          'gameBibliography': 'Bibliography',
          'gameTemplate': 'quiz',
          'questionsAndOptions': {
            'What is recycling?': ['Reusing materials', 'Throwing trash', 'Saving money', 'Buying new things'],
            'Why should we save water?': ['It helps the earth', 'Water is unlimited', 'For fun', 'It doesn’t matter']
          },
          'correctAnswers': {
            'What is recycling?': 'Reusing materials',
            'Why should we save water?': 'It helps the earth'
          },
          'documentName': 'game_1'
        },

        'game_game_2': {
          'gameLogo': 'assets/placeholder.png',
          'gameName': 'Game 12+',
          'gameDescription': 'description',
          'gameBibliography': 'Bibliography',
          'gameTemplate': 'quiz',
          'questionsAndOptions': {
            'What is recycling?': ['Reusing materials', 'Throwing trash', 'Saving money', 'Buying new things'],
            'Why should we save water?': ['It helps the earth', 'Water is unlimited', 'For fun', 'It doesn’t matter']
          },
          'correctAnswers': {
            'What is recycling?': 'Reusing materials',
            'Why should we save water?': 'It helps the earth'
          },
          'documentName': 'game_2'
        },

        'game_game_3': {
          'gameLogo': 'assets/placeholder.png',
          'gameName': 'Game 10+',
          'gameDescription': 'description',
          'gameBibliography': 'Bibliography',
          'gameTemplate': 'drag',
          'documentName': 'game_3'
        }
      });


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

      for (int i = 0; i < games.length; i++) {
        final docRef = fakeFirestore.collection('games').doc('game_$i');
        await docRef.set({
          'logo': games[i]['logo'],
          'name': games[i]['name'],
          'tags': games[i]['tags'],
          'description': games[i]['description'],
          'bibliography': games[i]['bibliography'],
          'template': games[i]['template'],
          'gameId': docRef.id,
        });
        games[i]['gameId'] = docRef.id;
      }

      gamecache = GameCacheService();
      testWidget = MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>(create: (_) => AuthService(firebaseAuth: auth)),
            Provider<FirestoreService>(create: (_) => FirestoreService(firestore: fakeFirestore)),
            Provider<UserCacheService>(create: (_) => UserCacheService()),
            Provider<GameCacheService>(create: (_) => gamecache),
            Provider<DataService>(create: (context) => DataService(context)),
          ],
          child: GamesPage(),
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

      expect(find.byType(GameCard), findsNWidgets(2)); // Ensure all 4 cards are initially rendered, value of 2 due to grid-view and scrolling
      await tester.enterText(find.byKey(Key('search')), 'Test');
      await tester.pumpAndSettle();

      expect(find.text('Test Game'), findsOneWidget);
      expect(find.text('Another Game'), findsNothing);
      expect(find.byType(GameCard), findsOneWidget); // Only 1 game should match search
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
      expect(find.byType(GameCard), findsOneWidget);
    });

    testWidgets('should reset age filter when "All Ages" is selected', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('ageDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('12+').last);
      await tester.pumpAndSettle();

      expect(find.byType(GameCard), findsOneWidget);

      await tester.tap(find.byKey(Key('ageDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All Ages').last); // Reset to All Ages
      await tester.pumpAndSettle();

      expect(find.byType(GameCard), findsNWidgets(2)); // All games should appear
    });

    testWidgets('should reset tag filter when "All Tags" is selected', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('tagDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Strategy').last);
      await tester.pumpAndSettle();

      expect(find.text('Test Game'), findsOneWidget);
      expect(find.byType(GameCard), findsNWidgets(2));

      await tester.tap(find.byKey(Key('tagDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All Tags').last);
      await tester.pumpAndSettle();

      expect(find.byType(GameCard), findsNWidgets(2));
    });

    testWidgets('should call load game correctly', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(find.byType(GamesInitialScreen), findsOneWidget);
    });

    testWidgets('should display no results found message if no games match the filters', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      await tester.enterText(find.byKey(Key('search')), 'Nonexistent');
      await tester.pumpAndSettle();

      expect(find.text('No results found'), findsOneWidget); // No games should match
    });
  });
}
