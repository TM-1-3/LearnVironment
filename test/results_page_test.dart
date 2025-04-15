import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/games_templates/results_page.dart';
import 'package:learnvironment/main_pages/games_page.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  group('ResultsPage Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late Widget testWidget;

    setUp(() {
      testWidget = MaterialApp(
        home: ResultsPage(
          questionsCount: 10,
          correctCount: 8,
          wrongCount: 2,
          gameName: 'EcoMind Challenge',
          gameImage: 'assets/quizLogo.png',
          tipsToAppear: ['Tip1', 'Tip2', 'Tip3'],
          duration: const Duration(minutes: 2, seconds: 10),
          onReplay: () => RandomGame()
        ),
      );
    });

    testWidgets('renders results and feedback', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.text('EcoMind Challenge Results'), findsOneWidget);
      expect(find.text('✅ Correct Answers: 8'), findsOneWidget);
      expect(find.text('❌ Wrong Answers: 2'), findsOneWidget);
      expect(find.textContaining('🕒 Time Taken: 2:10'), findsOneWidget);

      await tester.tap(find.text('Feedback'));
      await tester.pumpAndSettle();

      expect(find.text('Tip1'), findsOneWidget);
      expect(find.text('Tip2'), findsOneWidget);
      expect(find.text('Tip3'), findsOneWidget);
    });

    testWidgets('play again button navigates to new game', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      final playAgainBtn = find.widgetWithText(GestureDetector, 'Play Again');
      expect(playAgainBtn, findsOneWidget);

      await tester.ensureVisible(playAgainBtn);
      await tester.tap(playAgainBtn);
      await tester.pumpAndSettle();

      expect(find.byType(RandomGame), findsOneWidget);
    });

    testWidgets('Navigates to Games page', (WidgetTester tester) async {
      final testWidget = MaterialApp(
        home: ResultsPage(
            questionsCount: 10,
            correctCount: 8,
            wrongCount: 2,
            gameName: 'EcoMind Challenge',
            gameImage: 'assets/quizLogo.png',
            tipsToAppear: ['Tip1', 'Tip2', 'Tip3'],
            duration: const Duration(minutes: 2, seconds: 10),
            onReplay: () => RandomGame(),
        ),  // Assuming ResultsPage is the page with the "Back to Games Page" button
        routes: {
          '/games': (_) => GamesPage(skipFirebase: true),  // Use skipFirebase flag to avoid Firestore calls
        },
      );

      // Pump the widget
      await tester.pumpWidget(testWidget);

      // Find the "Back to Games Page" button
      final backBtn = find.widgetWithText(GestureDetector, 'Back to Games Page');
      expect(backBtn, findsOneWidget);

      // Ensure the button is visible
      await tester.ensureVisible(backBtn);
      await tester.pumpAndSettle();

      // Tap the button
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      // Check if the GamesPage is now visible (confirming navigation)
      expect(find.byType(GamesPage), findsOneWidget);
    });
  });
}

class RandomGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Random Game')),
    );
  }
}
