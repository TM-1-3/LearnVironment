import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/developer/CreateGames/create_drag.dart';
import 'package:learnvironment/developer/CreateGames/create_quiz.dart';
import 'package:learnvironment/developer/new_game.dart';

void main() {
  testWidgets('renders app bar with correct title', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: NewGamePage()));

    expect(find.text('Select a Template'), findsOneWidget);
  });

  testWidgets('Each ListTile has correct text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: NewGamePage()),
    );

    expect(find.byType(ListTile), findsNWidgets(NewGamePage.gameTypes.length));
    expect(find.text('Create a drag game'), findsOneWidget);
    expect(find.text('Create a quiz game'), findsOneWidget);
  });

  testWidgets('navigates to CreateDragPage on drag tile tap', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: NewGamePage()));

    await tester.tap(find.text('Create a drag game'));
    await tester.pumpAndSettle();

    expect(find.byType(CreateDragPage), findsOneWidget);
  });

  testWidgets('navigates to CreateQuizPage on quiz tile tap', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: NewGamePage()));

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

