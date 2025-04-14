import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/games_templates/games_initial_screen.dart';
import 'package:learnvironment/main_pages/games_page.dart';
import 'package:learnvironment/main_pages/widgets/game_card.dart';
import 'package:learnvironment/services/firestore_service.dart';

// Mock Firestore Service
class MockFirestoreService extends FirestoreService {
  MockFirestoreService({super.firestore});

  List<Map<String, dynamic>> _mockGames = [];

  // Set mock data with correct format
  void setMockGames(List<Map<String, dynamic>> games) {
    _mockGames = games.map((game) {
      return {
        'imagePath': game['logo'] ?? 'assets/placeholder.png',
        'gameTitle': game['name'] ?? 'Default Game Title',
        'tags': List<String>.from(game['tags'] ?? []),
        'gameId': game['gameId'],
      };
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getAllGames() async {
    return Future.value(_mockGames);
  }

  @override
  Future<GameData> fetchGameData(String gameId) async {
    final game = _mockGames.firstWhere((g) => g['gameId'] == gameId);
    return GameData(
      documentName: game['gameId'],
      gameName: game['gameTitle'],
      gameDescription: game['description'],
      gameBibliography: game['bibliography'],
      gameTemplate: game['template'],
      gameLogo: game['imagePath'],
      tags: List<String>.from(game['tags']),
    );
  }
}

void main() {
  group('GamesPage Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth auth;
    late Widget testWidget;
    late MockFirestoreService firestoreService;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth(mockUser: MockUser(
      uid: 'test_uid',
      email: 'test@example.com',
      ), signedIn: true);

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
        },
        {
          'logo': 'assets/placeholder.png',
          'name': 'Game 12+',
          'tags': ['Age: 12+', 'Strategy'],
          'description': 'description',
          'bibliography': 'Bibliography',
          'template': 'quiz',
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

      firestoreService = MockFirestoreService(firestore: fakeFirestore);
      firestoreService.setMockGames(games);
      testWidget = MaterialApp(
        home: GamesPage(firestore: fakeFirestore, auth: auth, firestoreService: firestoreService),
      );
    });
    
    testWidgets('should display search bar', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

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
      await tester.tap(find.text('All Tags').last); // Reset to All Tags
      await tester.pumpAndSettle();

      expect(find.byType(GameCard), findsNWidgets(2)); // All games should appear
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
