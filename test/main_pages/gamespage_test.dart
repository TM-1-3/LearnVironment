import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/main_pages/games_page.dart';
import 'package:learnvironment/main_pages/widgets/game_card.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();

    final games = [
      {
        'logo': 'assets/placeholder.png',
        'name': 'Test Game',
        'tags': ['Strategy'],
        'description' : 'description',
        'bibliography' : 'Bibliography',
        'template' : 'drag'
      },
      {
        'logo': 'assets/placeholder.png',
        'name': 'Another Game',
        'tags': ['Citizenship'],
        'description' : 'description',
        'bibliography' : 'Bibliography',
        'template' : 'quiz'
      },
      {
        'logo': 'assets/placeholder.png',
        'name': 'Game 12+',
        'tags': ['Age: 12+', 'Strategy'],
        'description' : 'description',
        'bibliography' : 'Bibliography',
        'template' : 'quiz'
      },
      {
        'logo': 'assets/placeholder.png',
        'name': 'Game 10+',
        'tags': ['Age: 10+', 'Citizenship'],
        'description' : 'description',
        'bibliography' : 'Bibliography',
        'template' : 'drag'
      },
    ];

    //Add games to my firestore mock
    for (int i = 0; i < games.length; i++) {
      final docRef = fakeFirestore.collection('games').doc('game_$i');
      await docRef.set(games[i]);
    }
  });

  group('GamesPage Tests', () {
    testWidgets('should display search bar', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GamesPage(firestore: fakeFirestore),
      ));

      // Find the search bar widget and check if it's present
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should filter games by search query', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GamesPage(firestore: fakeFirestore),
      ));

      await tester.pumpAndSettle();
      // Ensure that all game cards are visible before applying the filter
      expect(find.byType(GameCard), findsNWidgets(4)); // Expecting 4 games initially

      // Simulate typing in search query
      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump();

      // Verify the filtered list is correct
      expect(find.text('Test Game'), findsOneWidget); // The filtered game
      expect(find.text('Another Game'), findsNothing); // This should not be visible
      expect(find.byType(GameCard), findsOneWidget); // Only one GameCard should be visible after filtering
    });

    testWidgets('should filter games by age tag', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GamesPage(firestore: fakeFirestore),
      ));

      await tester.pumpAndSettle();

      // Filter by Age 12+
      await tester.tap(find.byKey(Key('ageDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('12+').last);
      await tester.pump();

      // Verify filtered games are shown correctly
      expect(find.text('Game 12+'), findsOneWidget); // This should be visible after filtering
      expect(find.text('Game 10+'), findsNothing); // This should not be visible
      expect(find.byType(GameCard), findsOneWidget); // Only one GameCard should be visible after filtering
    });

    testWidgets('should call load game correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GamesPage(firestore: fakeFirestore),
      ));

      await tester.pumpAndSettle();

      // Tap on the first game card (GestureDetector widget)
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(find.byType(ScaffoldMessenger), findsOneWidget);
    });

    testWidgets('should display no results found message if no games match the filters', (WidgetTester tester) async {
      // Simulate typing a query that won't match
      await tester.pumpWidget(MaterialApp(
        home: GamesPage(firestore: fakeFirestore),
      ));

      await tester.enterText(find.byType(TextField), 'Nonexistent');
      await tester.pump();

      // Verify "No results found" text is displayed
      expect(find.text('No results found'), findsOneWidget);
    });
  });
}
