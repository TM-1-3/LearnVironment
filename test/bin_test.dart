import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/main_pages/game_data.dart';
import 'package:mockito/mockito.dart';
import 'package:learnvironment/bin.dart';
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

    // Verify bins are shown
    expect(find.byType(DragTarget<String>), findsNWidgets(5));

    // Verify all 4 initial trash items
    expect(find.byType(Draggable<String>), findsNWidgets(4));
    expect(find.image(const AssetImage('assets/trash1.png')), findsOneWidget);
    expect(find.image(const AssetImage('assets/trash2.png')), findsOneWidget);
    expect(find.image(const AssetImage('assets/trash3.png')), findsOneWidget);
    expect(find.image(const AssetImage('assets/trash4.png')), findsOneWidget);
  });

  testWidgets('Dropping correct item into correct bin increments correctCount', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    final state = tester.state<BinScreenState>(find.byType(BinScreen));

    fakeAsync((async) {
      final initialCorrectCount = state.correctCount;

      state.removeTrashItem('trash1', 'brown', Offset.zero);
      async.elapse(Duration(seconds: 1)); // Simulate time passing

      expect(state.correctCount, initialCorrectCount + 1);
      expect(state.trashItems.containsKey('trash1'), isFalse);
    });
  });

  testWidgets('Dropping wrong item into incorrect bin increments wrongCount', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    final state = tester.state<BinScreenState>(find.byType(BinScreen));

    fakeAsync((async) {
      final initialWrongCount = state.wrongCount;

      state.removeTrashItem('trash2', 'blue', Offset.zero);
      async.elapse(Duration(seconds: 1)); // Simulate time passing

      expect(state.wrongCount, initialWrongCount + 1);
      expect(state.trashItems.containsKey('trash2'), isFalse);
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
