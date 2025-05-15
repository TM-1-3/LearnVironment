import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/developer/widgets/my_game_card.dart';
import 'package:learnvironment/developer/edit_game.dart';

void main() {
  testWidgets('tapping edit icon navigates to EditGame', (WidgetTester tester) async {
    Future<void> loadGame(String gameId) async {}

    final widget = MaterialApp(
      home: Scaffold(
        body: MyGameCard(
          imagePath: 'assets/placeholder.png',
          gameTitle: 'Test Game',
          tags: ['Tag1', 'Tag2'],
          gameId: 'g1',
          loadGame: loadGame,
          isPublic: true,
        ),
      ),
      routes: {
        '/edit': (context) => EditGame(gameId: 'g1'),
      },
    );

    await tester.pumpWidget(widget);

    await tester.tap(find.byKey(Key("edit")));
    await tester.pumpAndSettle();

    expect(find.byType(EditGame), findsOneWidget);
  });
}
