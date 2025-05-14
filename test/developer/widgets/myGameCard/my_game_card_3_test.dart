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
  testWidgets('shows "+X more" when more than 3 tags', (WidgetTester tester) async {
    Future<void> loadGame(String gameId) async {}

    final widget = buildTestableWidget(MyGameCard(
      imagePath: 'assets/placeholder.png',
      gameTitle: 'Test Game',
      tags: ['Tag1', 'Tag2', 'Tag3', 'Tag4', 'Tag5'],
      gameId: 'g1',
      loadGame: loadGame,
      isPublic: true,
    ));

    await tester.pumpWidget(widget);

    expect(find.text('Make Private'), findsOneWidget);
    expect(find.byType(TagWidget), findsNWidgets(3));
    expect(find.text('+3 more'), findsOneWidget);
  });
}
