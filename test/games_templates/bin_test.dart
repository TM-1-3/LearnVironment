import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:mockito/mockito.dart';
import 'package:learnvironment/games_templates/bin.dart';
import 'package:fake_async/fake_async.dart';

class MockGameData extends Mock implements GameData {
  @override
  String get gameLogo => 'assets/widget.png';

  @override
  String get gameName => 'Bin Game';

  @override
  String get gameDescription => 'Match the right piece of trash to the correct bin';

  @override
  String get gameBibliography => 'Bibliography';

  @override
  List<String> get tags => ['8+'];

  @override
  Map<String,String> get tips => {
    "trash1": "Organic trash goes to the brown can",
    "trash2": "Batteries go to the red can",
    "trash3": "Plastic and metal go to the yellow can",
    "trash4": "Paper and cardboard go to the blue can",
    "trash5": "Glass goes to the green can",
    "trash6": "Paper and cardboard go to the blue can",
    "trash7": "Batteries go to the red can",
    "trash8": "Glass goes to the green can",
    "trash9": "Plastic and metal go to the yellow can",
    "trash10": "Organic trash goes to the brown can",
  };

  @override
  Map<String, String> get correctAnswers => {
    "assets/trash1.png": "brown",
    "assets/trash2.png": "red",
    "assets/trash3.png": "yellow",
    "assets/trash4.png": "blue",
    "assets/trash5.png": "green",
    "assets/trash6.png": "blue",
    "assets/trash7.png": "red",
    "assets/trash8.png": "green",
    "assets/trash9.png": "yellow",
    "assets/trash10.png": "brown",
  };
}

void main() {
  late MockGameData binData;
  late Widget testWidget;

  setUp(() {
    binData = MockGameData();
    testWidget = MaterialApp(
      home: BinScreen(binData: binData),
    );
  });

  testWidgets('BinScreen renders all bins and trash items', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    expect(find.byType(DragTarget<String>), findsNWidgets(5));
    expect(find.byType(Draggable<String>), findsNWidgets(4));
  });

  testWidgets('Dropping correct item into correct bin increments correctCount', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    final state = tester.state<BinScreenState>(find.byType(BinScreen));

    fakeAsync((async) {
      final Map<String, String> trashItems = state.trashItems;
      final firstEntry = trashItems.entries.first;
      state.removeTrashItem(firstEntry.key, firstEntry.value, Offset.zero);
      async.elapse(Duration(seconds: 1)); // Simulate time passing

      expect(state.correctCount, 1);
      expect(state.trashItems.containsKey(firstEntry.key), isFalse);
    });
  });

  testWidgets('Dropping wrong item into incorrect bin increments wrongCount', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    final state = tester.state<BinScreenState>(find.byType(BinScreen));

    fakeAsync((async) {
      final Map<String, String> trashItems = state.trashItems;
      final firstEntry = trashItems.entries.first;
      if (firstEntry.value == "blue") {
        state.removeTrashItem(firstEntry.key, "brown", Offset.zero);
      } else {
        state.removeTrashItem(firstEntry.key, "blue", Offset.zero);
      }

      expect(state.wrongCount, 1);
      expect(state.trashItems.containsKey(firstEntry.key), isFalse);
    });
  });

  testWidgets('Game refills trash items from remainingTrashItems after removing one', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    final state = tester.state<BinScreenState>(find.byType(BinScreen));

    fakeAsync((async) {
      final initialRemainingCount = state.remainingTrashItems.length;
      final nextTrash = state.remainingTrashItems.keys.first;

      state.removeTrashItem('trash1', 'brown', Offset.zero); // correct bin
      async.elapse(const Duration(seconds: 1)); // simulate delayed future

      // Now test the state after delay
      expect(state.trashItems.containsKey(nextTrash), isTrue);
      expect(state.remainingTrashItems.length, initialRemainingCount - 1);
    });
  });

  testWidgets('Game is over when all trashItems and remainingTrashItems are empty', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    final state = tester.state<BinScreenState>(find.byType(BinScreen));

    // Clear all items
    state.trashItems.clear();
    state.remainingTrashItems.clear();

    expect(state.isGameOver(), isTrue);
  });
}
