import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/developer/widgets/dropdown/tag_selection.dart';

void main() {
  group('TagSelection Widget', () {
    testWidgets('displays all available tags', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagSelection(
              selectedTags: [],
              onTagsUpdated: (_) {},
            ),
          )
        ),
      );

      expect(find.text('Select Tags'), findsOneWidget);
      expect(find.text('Recycling'), findsOneWidget);
      expect(find.text('Strategy'), findsOneWidget);
      expect(find.text('Citizenship'), findsOneWidget);
    });

    testWidgets('initially shows selected tags correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagSelection(
              selectedTags: ['Recycling'],
              onTagsUpdated: (_) {},
            ),
          )
        ),
      );

      final chip = tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Recycling'));
      expect(chip.selected, isTrue);

      final unselectedChip = tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Strategy'));
      expect(unselectedChip.selected, isFalse);
    });

    testWidgets('selecting a tag adds it to selectedTags and triggers callback', (WidgetTester tester) async {
      List<String> updatedTags = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagSelection(
              selectedTags: [],
              onTagsUpdated: (tags) => updatedTags = tags,
            )
          ),
        ),
      );

      await tester.tap(find.text('Recycling'));
      await tester.pumpAndSettle();

      expect(updatedTags, contains('Recycling'));
    });

    testWidgets('deselecting a tag removes it from selectedTags and triggers callback', (WidgetTester tester) async {
      List<String> updatedTags = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagSelection(
              selectedTags: ['Recycling'],
              onTagsUpdated: (tags) => updatedTags = tags,
            )
          ),
        ),
      );

      await tester.tap(find.text('Recycling'));
      await tester.pumpAndSettle();

      expect(updatedTags, isNot(contains('Recycling')));
    });

    testWidgets('selecting multiple tags updates the selectedTags correctly', (WidgetTester tester) async {
      List<String> updatedTags = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagSelection(
              selectedTags: [],
              onTagsUpdated: (tags) => updatedTags = tags,
            )
          ),
        ),
      );

      await tester.tap(find.text('Recycling'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Strategy'));
      await tester.pumpAndSettle();

      expect(updatedTags, containsAll(['Recycling', 'Strategy']));
    });
  });
}
