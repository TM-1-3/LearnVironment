import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/developer/CreateGames/objects/trash_object.dart';
import 'package:learnvironment/developer/widgets/dropdown/trash_can_dropdown.dart';
import 'package:learnvironment/developer/widgets/forms/trash_object_form.dart';
import 'package:learnvironment/developer/widgets/game_form_field.dart';

void main() {
  late TrashObject trashObject;
  late List<bool> isExpandedList;
  late int removedIndex;
  late List<bool> updatedIsExpandedList;

  setUp(() {
    trashObject = TrashObject();
    isExpandedList = List<bool>.filled(10, true);
    removedIndex = -1;
    updatedIsExpandedList = [];
  });

  Widget createWidgetUnderTest({int index = 0}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: TrashObjectForm(
            trashObject: trashObject,
            index: index,
            isExpandedList: isExpandedList,
            onIsExpandedList: (list) => updatedIsExpandedList = list,
            onRemove: (index) => removedIndex = index,
          ),
        ),
      ),
    );
  }

  testWidgets('renders TrashObjectForm with required fields', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Object 1'), findsOneWidget);
    expect(find.byType(GameFormField), findsNWidgets(2));
    expect(find.byType(TrashCanDropdown), findsOneWidget);
  });

  testWidgets('shows Remove button if index >= 4', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(index: 4));

    expect(find.text('Remove'), findsOneWidget);
  });

  testWidgets('does not show Remove button if index < 4', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(index: 2));

    expect(find.text('Remove'), findsNothing);
  });

  testWidgets('Remove button triggers onRemove callback', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(index: 4));

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(removedIndex, 4);
  });

  testWidgets('expansion triggers onIsExpandedList callback', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Object 1'));
    await tester.pumpAndSettle();

    expect(updatedIsExpandedList[0], false);
  });

  testWidgets('collapse shows SnackBar if fields are empty', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Object 1')); // expand
    await tester.pumpAndSettle();
    await tester.tap(find.text('Object 1')); // collapse
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Please fill in all fields for Object 1'), findsOneWidget);
  });

  testWidgets('form fields validate non-empty input', (tester) async {
    trashObject.imageUrlController.text = 'image.png';
    trashObject.tipController.text = 'Helpful tip';

    await tester.pumpWidget(createWidgetUnderTest());

    expect(
      (tester.firstWidget(find.byType(GameFormField)) as GameFormField)
          .validator!(''),
      'This field is required',
    );
  });
}
