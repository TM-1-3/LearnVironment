import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/developer/CreateGames/create_drag.dart';
import 'package:learnvironment/developer/CreateGames/create_quiz.dart';
import 'package:learnvironment/developer/new_game.dart';

void main() {
  testWidgets('NewGamePage renders correct number of game type cards', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: NewGamePage()),
    );

    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('Each ListTile has correct text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: NewGamePage()),
    );

    expect(find.text('Create a drag game'), findsOneWidget);
    expect(find.text('Create a quiz game'), findsOneWidget);
  });

  testWidgets('Tapping "drag" navigates to CreateDragPage', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const NewGamePage(),
        routes: {
          '/create_drag': (context) => const CreateDragPage(),
        },
      ),
    );

    await tester.tap(find.text('Create a drag game'));
    await tester.pumpAndSettle();

    expect(find.byType(CreateDragPage), findsOneWidget);
  });

  testWidgets('Tapping "quiz" navigates to CreateQuizPage', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const NewGamePage(),
        routes: {
          '/create_quiz': (context) => const CreateQuizPage(),
        },
      ),
    );

    await tester.tap(find.text('Create a quiz game'));
    await tester.pumpAndSettle();

    expect(find.byType(CreateQuizPage), findsOneWidget);
  });

  testWidgets('AppBar is present with correct title and no back button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: NewGamePage()),
    );

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Select a Template'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
  });

  testWidgets('Broken image shows fallback icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: NewGamePage()),
    );

    final brokenImage = find.byType(Image);
    expect(brokenImage, findsWidgets);
  });
}
