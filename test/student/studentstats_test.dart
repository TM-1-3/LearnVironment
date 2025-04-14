import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/games_templates/games_initial_screen.dart';
import 'package:learnvironment/main_pages/widgets/game_card.dart';
import 'package:learnvironment/student/student_stats.dart';

void main() {
  group('StudentStatsPage Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late Widget testWidget;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();

      // Sample game data
      final games = [
        {
          'imagePath': 'assets/placeholder.png',
          'gameTitle': 'Test Game',
          'tags': ['Strategy'],
          'gameId': 'game_1',
        },
        {
          'imagePath': 'assets/placeholder.png',
          'gameTitle': 'Another Game',
          'tags': ['Citizenship'],
          'gameId': 'game_2',
        },
        {
          'imagePath': 'assets/placeholder.png',
          'gameTitle': 'Game 12+',
          'tags': ['Age: 12+', 'Strategy'],
        },
        {
          'imagePath': 'assets/placeholder.png',
          'gameTitle': 'Game 10+',
          'tags': ['Age: 10+', 'Citizenship'],
        },
      ];

      for (int i = 0; i < games.length; i++) {
        final docRef = fakeFirestore.collection('games').doc('game_$i');
        await docRef.set({
          'logo': games[i]['imagePath'],
          'name': games[i]['gameTitle'],
          'tags': games[i]['tags'],
          'gameId': docRef.id,
          'template' : 'drag',
          'description' : 'description',
          'bibliography' : 'bibliography'
        });
      }

      testWidget = MaterialApp(
        home: StudentStatsPage(),
      );
    });

    testWidgets('should display game cards when games are loaded', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      expect(find.byType(GameCard), findsNWidgets(2)); // 2 games should be rendered due to scrolling
    });

    testWidgets('should display message if no games are played', (WidgetTester tester) async {
      // Simulate no games in Firestore
      fakeFirestore.collection('games').get().then((snapshot) {
        return snapshot.docs.isEmpty;
      });

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      expect(find.text('No games have been played yet!'), findsOneWidget);
    });

    testWidgets('should navigate to game details when game card is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Tap on the first game card
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(find.byType(GamesInitialScreen), findsOneWidget);
    });

    testWidgets('should display an error if no games are available', (WidgetTester tester) async {
      // Simulate Firestore returning empty data
      final emptyFirestore = FakeFirebaseFirestore();

      testWidget = MaterialApp(
        home: StudentStatsPage(),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      expect(find.text('No games have been played yet!'), findsOneWidget); // Expect no games message
    });
  });
}
