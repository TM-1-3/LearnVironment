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
  testWidgets('renders correctly with no tags', (WidgetTester tester) async {
    Future<void> loadGame(String gameId) async {}

    final widget = buildTestableWidget(MyGameCard(
      imagePath: 'assets/placeholder.png',
      gameTitle: 'Test Game',
      tags: [],
      gameId: 'g1',
      loadGame: loadGame,
      isPublic: true,
    ));

    await tester.pumpWidget(widget);

    expect(find.byType(TagWidget), findsNothing);
    expect(find.text('+1 more'), findsNothing);
  });
}
