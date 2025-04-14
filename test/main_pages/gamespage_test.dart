import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/main_pages/games_page.dart';
import 'package:learnvironment/main_pages/widgets/game_card.dart';

void main() {
  group('GamesPage Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late Widget testWidget;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();

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
          'gameId': docRef,
        });
      }

      testWidget = MaterialApp(
        home: GamesPage(firestore: fakeFirestore),
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

      // Test load game functionality by tapping on the first card
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(find.byType(ScaffoldMessenger), findsOneWidget);
    });

    testWidgets('should display no results found message if no games match the filters', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      await tester.enterText(find.byKey(Key('search')), 'Nonexistent');
      await tester.pumpAndSettle();

      expect(find.text('No results found'), findsOneWidget); // No games should match
    });
  });
}
