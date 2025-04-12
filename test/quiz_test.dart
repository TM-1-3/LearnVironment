import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/games_templates/results_page.dart';
import 'package:learnvironment/main_pages/game_data.dart';
import 'package:learnvironment/games_templates/quiz.dart';
import 'package:mockito/mockito.dart';

class MockGameData extends Mock implements GameData {
  @override
  String get gameLogo => 'assets/quizLogo.png';

  @override
  String get gameName => 'EcoMind Challenge';

  @override
  String get gameDescription => 'Quiz About Environment And Sustainability';

  @override
  String get gameBibliography => 'Bibliography';

  @override
  List<String> get tags => ['12+'];
}

void main() {
  group('Quiz App Tests', () {
    late MockGameData quizData;
    late Widget testWidget;

    setUp(() {
      quizData = MockGameData();

      testWidget = MaterialApp(
        home: Quiz(quizData: quizData),
      );
    });

    testWidgets('Renders start page correctly', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      expect(find.text('EcoMind Challenge'), findsNWidgets(2));
      expect(find.byWidgetPredicate((widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == "assets/quizLogo.png"), findsOneWidget);
      expect(find.byWidgetPredicate((widget) => widget is Text && widget.data == 'EcoMind Challenge' && widget.style?.fontSize == 28 && widget.style?.fontWeight == FontWeight.bold), findsOneWidget);
      expect(find.text('Start Quiz'), findsOneWidget);
    });

    testWidgets('Start Quiz starts the quiz', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.ensureVisible(find.text('Start Quiz'));
      await tester.tap(find.text('Start Quiz'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Question 1'), findsOneWidget);
    });

    testWidgets('Quiz is executed', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.ensureVisible(find.text('Start Quiz'));
      await tester.tap(find.text('Start Quiz'));
      await tester.pumpAndSettle();

      // Simulate answering questions.
      int questionNumber = 1;
      while (questionNumber <= 10) {
        expect(find.text('Question $questionNumber'), findsOneWidget); // Validate question number.
        final answerCards = find.byType(GestureDetector);
        expect(answerCards, findsWidgets); // Ensure answers exist

        // Tap the first answer card
        await tester.tap(answerCards.first);
        await tester.pumpAndSettle(); // Wait for state update
        await tester.pump(Duration(seconds: 2));
        questionNumber++;
      }

      // Verify the results screen.
      await tester.pumpAndSettle();
      expect(find.byType(ResultsPage), findsOneWidget);
    });

    testWidgets('Quiz delivers feedback', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Start quiz.
      await tester.tap(find.text('Start Quiz'));
      await tester.pumpAndSettle(); // Wait for quiz screen to load

      final imageFinder = find.byWidgetPredicate((widget) {
        if (widget is Image) {
          final imageAsset = widget.image;
          return (imageAsset is AssetImage) &&
              (imageAsset.assetName == 'assets/right.png' || imageAsset.assetName == 'assets/wrong.png');
        }
        return false;
      });

      // Answer all questions.
      for (int i = 1; i <= 10; i++) {
        expect(find.text('Question $i'), findsOneWidget);
        final answerCards = find.byType(GestureDetector);
        expect(answerCards, findsNWidgets(4));
        await tester.tap(answerCards.first);
        await tester.pumpAndSettle(); // Wait for state update
        expect(imageFinder, findsOneWidget);
        await tester.pump(Duration(seconds: 2));
      }

      await tester.pumpAndSettle();
      expect(find.byType(ResultsPage), findsOneWidget);
      expect(find.byType(GestureDetector), findsNWidgets(2));
    });
  });
}
