import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/developer/CreateGames/objects/option_object.dart';
import 'package:learnvironment/developer/widgets/forms/options_object_form.dart';
import 'package:learnvironment/developer/widgets/game_form_field.dart';

void main() {
  group('OptionsObjectForm', () {
    late OptionObject optionObject;
    late List<bool> isExpandedList;
    late ValueChanged<List<bool>> onIsExpandedList;

    setUp(() {
      optionObject = OptionObject();
      isExpandedList = [true];
      onIsExpandedList = (expandedList) {
          isExpandedList = expandedList;
      };
    });

    testWidgets('should display initial state with title and form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptionsObjectForm(
              optionObject: optionObject,
              index: 0,
              onIsExpandedList: onIsExpandedList,
              isExpandedList: isExpandedList,
            ),
          ),
        ),
      );

      // Verify the title
      expect(find.text('Options for Question number 1'), findsOneWidget);

      // Verify form fields
      expect(find.byType(GameFormField), findsNWidgets(4));
      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Option 2'), findsOneWidget);
      expect(find.text('Option 3'), findsOneWidget);
      expect(find.text('Option 4'), findsOneWidget);
    });

    testWidgets('should expand and collapse the ExpansionTile correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptionsObjectForm(
              optionObject: optionObject,
              index: 0,
              onIsExpandedList: onIsExpandedList,
              isExpandedList: isExpandedList,
            ),
          ),
        ),
      );

      expect(find.byType(ExpansionTile), findsOneWidget);
      expect(isExpandedList[0], isTrue);

      await tester.tap(find.text("Options for Question number 1"));
      await tester.pumpAndSettle();
      expect(isExpandedList[0], isFalse);

      await tester.tap(find.text("Options for Question number 1"));
      await tester.pumpAndSettle();
      expect(isExpandedList[0], isTrue);
    });

    testWidgets('should show SnackBar if the tile collapses and fields are empty', (WidgetTester tester) async {
      optionObject = OptionObject(); // Ensure fields are empty

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptionsObjectForm(
              optionObject: optionObject,
              index: 0,
              onIsExpandedList: onIsExpandedList,
              isExpandedList: isExpandedList,
            ),
          ),
        ),
      );

      await tester.tap(find.text("Options for Question number 1"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Options for Question number 1"));
      await tester.pumpAndSettle();

      // Check that a SnackBar is shown
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Please fill in all fields for Object 1'), findsOneWidget);
    });

    testWidgets('should trigger the onIsExpandedList callback correctly when expanded or collapsed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptionsObjectForm(
              optionObject: optionObject,
              index: 0,
              onIsExpandedList: onIsExpandedList,
              isExpandedList: isExpandedList,
            ),
          ),
        ),
      );

      expect(isExpandedList[0], isTrue);

      await tester.tap(find.text("Options for Question number 1"));
      await tester.pumpAndSettle();

      expect(isExpandedList[0], isFalse);

      await tester.tap(find.text("Options for Question number 1"));
      await tester.pumpAndSettle();

      expect(isExpandedList[0], isTrue);
    });
  });
}
