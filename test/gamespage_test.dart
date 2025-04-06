import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/main_pages/game_data.dart';
import 'package:learnvironment/main_pages/games_page.dart';
import 'package:mocktail/mocktail.dart';

// Mock the GameData class and its fetchGameData method
class MockGameData extends Mock implements GameData {
  Future<GameData> fetchGameData(String gameId) async {
    // Return a mock GameData object
    return GameData(
      gameName: 'EcoMind Challenge',
      tags: ['Recycling', 'Citizenship', '12+'],
      gameLogo: 'logo_path',
      gameDescription: 'This is a game about recycling and citizenship.',
      gameBibliography: 'Game bibliography here.',
    );
  }
}

// Mock NavigatorObserver to test navigation
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// Mock ScaffoldMessengerState to capture showSnackBar calls
class MockScaffoldMessengerState extends Mock implements ScaffoldMessengerState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MockScaffoldMessengerState';
  }
}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  group('Widget Tests', () {
    late Widget testWidget;
    setUp(() {
      testWidget = MaterialApp(home: GamesPage());
    });

    testWidgets('Test age and tag dropdown filtering', (tester) async {
      // Create the widget and mount it
      await tester.pumpWidget(testWidget);

      // Find the dropdowns for Age and Tag
      final ageDropdown = find.byKey(Key('ageDropdown'));
      final tagDropdown = find.byKey(Key('tagDropdown'));

      expect(find.byType(DropdownButton<String>), findsNWidgets(2));

      // Tap on the Age dropdown and select "12+"
      await tester.ensureVisible(ageDropdown);
      await tester.tap(ageDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('12+').last);  // Select "12+" from the list
      await tester.pumpAndSettle();

      // Verify that the dropdown value is updated to "12+"
      expect(find.text('12+'), findsOneWidget);

      // Tap on the Tag dropdown and select "Recycling"
      await tester.ensureVisible(tagDropdown);
      await tester.tap(tagDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Recycling').last);  // Select "Recycling" from the list
      await tester.pumpAndSettle();

      // Verify that the dropdown value is updated to "Recycling"
      expect(find.text('Recycling'), findsNWidgets(2));

      // Verify that the filtered games are now displayed based on the selected filters
      final filteredGames = tester.widgetList<GameCard>(find.byType(GameCard));
      final filteredGameTitles = filteredGames
          .map((gameCard) => (gameCard.gameTitle)).toList();

      // We expect games with the "Recycling" tag and "12+" age filter
      expect(filteredGameTitles, contains('EcoMind Challenge'));
      expect(filteredGameTitles.length, 1);  // Ensure the filtering resulted in only 1 game
    });

    testWidgets('GamesPage displays search bar and game cards', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Verify the search bar is present
      expect(find.byType(TextField), findsOneWidget);

      // Verify the first game card is present
      expect(find.byType(GameCard), findsAtLeastNWidgets(1));

      // Verify dropdown buttons for filtering
      expect(find.byType(DropdownButton<String>), findsNWidgets(2));

      // Check for "No results found" with an empty search
      await tester.enterText(find.byType(TextField), 'Nonexistent Game');
      await tester.pump();
      expect(find.text('No results found'), findsOneWidget);
    });

    testWidgets('Test search query updates', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Enter text in the search bar
      await tester.enterText(find.byType(TextField), 'EcoMind');
      await tester.pump();

      // Verify filtered results match the search text
      expect(find.text('EcoMind Challenge'), findsOneWidget);
      expect(find.text('Game Title 2'), findsNothing);
    });

    testWidgets('Test age filter updates', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Tap on the age filter and select "12+"
      await tester.tap(find.byType(DropdownButton<String>).first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('12+').last);
      await tester.tap(find.text('12+').last);
      await tester.pump();

      // Ensure EcoMind Challenge is visible after filtering
      expect(find.text('EcoMind Challenge'), findsOneWidget);
    });

    testWidgets('Test tag filter updates', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Tap on the tag filter and select "Recycling"
      await tester.tap(find.byType(DropdownButton<String>).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Recycling').last);
      await tester.pump();

      // Ensure games matching "Recycling" tag are visible
      expect(find.text('EcoMind Challenge'), findsOneWidget);
      expect(find.text('Game Title 2'), findsOneWidget);
      expect(find.text('Game Title 3'), findsNothing);
    });
  });
}
