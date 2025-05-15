import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/developer/CreateGames/objects/question_object.dart';
import 'package:learnvironment/developer/widgets/dropdown/option_dropdown.dart';
import 'package:learnvironment/developer/widgets/forms/options_object_form.dart';
import 'package:learnvironment/developer/widgets/forms/question_object_form.dart';
import 'package:learnvironment/developer/widgets/game_form_field.dart';

void main() {
  late QuestionObject questionObject;
  late List<bool> isExpandedList;
  late List<bool> isExpandedListOpt;
  late int removedIndex;
  late List<bool> updatedIsExpandedList;

  setUp(() {
    questionObject = QuestionObject();
    isExpandedList = List<bool>.filled(10, true);
    isExpandedListOpt = List<bool>.filled(10, true);
    removedIndex = -1;
    updatedIsExpandedList = [];
  });

  Widget createWidgetUnderTest({int index = 0}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: QuestionObjectForm(
            questionObject: questionObject,
            index: index,
            isExpandedList: isExpandedList,
            isExpandedListOpt: isExpandedListOpt,
            onIsExpandedList: (list) => updatedIsExpandedList = list,
            onIsExpandedListOpt: (list) => {},
            onRemove: (index) => removedIndex = index,
          ),
        ),
      )
    );
  }

  testWidgets('renders QuestionObjectForm with required fields', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Question 1'), findsOneWidget);
    expect(find.byType(GameFormField), findsNWidgets(6));
    expect(find.byType(OptionsObjectForm), findsOneWidget);
    expect(find.byType(OptionDropdown), findsOneWidget);
  });

  testWidgets('shows Remove button if index >= 5', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(index: 5));

    expect(find.text('Remove'), findsOneWidget);
  });

  testWidgets('does not show Remove button if index < 5', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(index: 2));

    expect(find.text('Remove'), findsNothing);
  });

  testWidgets('Remove button triggers onRemove callback', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(index: 5));

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(removedIndex, 5);
  });

  testWidgets('expansion triggers onIsExpandedList callback', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Question 1'));
    await tester.pumpAndSettle();

    expect(updatedIsExpandedList[0], false);
  });

  testWidgets('collapse shows SnackBar if fields are empty', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Question 1')); // expand
    await tester.pumpAndSettle();
    await tester.tap(find.text('Question 1')); // collapse
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Please fill in all fields for Question 1'), findsOneWidget);
  });

  testWidgets('form fields validate non-empty input', (tester) async {
    questionObject.questionController.text = 'Q1';
    questionObject.tipController.text = 'Tip';

    await tester.pumpWidget(createWidgetUnderTest());

    expect(
      (tester.firstWidget(find.byType(GameFormField)) as GameFormField)
          .validator!(''),
      'This field is required',
    );
  });
}
