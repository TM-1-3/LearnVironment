import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/developer/widgets/my_game_card.dart';
import 'package:learnvironment/main_pages/widgets/tag.dart';

Widget buildTestableWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('renders image, title, tags, and edit button', (WidgetTester tester) async {
    Future<void> loadGame(String gameId) async {}

    final widget = buildTestableWidget(MyGameCard(
      imagePath: 'assets/placeholder.png',
      gameTitle: 'Test Game',
      tags: ['Tag1', 'Tag2'],
      gameId: 'g1',
      loadGame: loadGame,
    ));

    await tester.pumpWidget(widget);

    expect(find.text('Test Game'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byType(TagWidget), findsNWidgets(2));
  });
}