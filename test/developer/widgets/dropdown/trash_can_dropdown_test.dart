import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/developer/widgets/dropdown/trash_can_dropdown.dart';

void main() {
  testWidgets('renders dropdown with correct hint and label', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrashCanDropdown(
            selectedOption: null,
            onOptionSelected: (_) {},
          ),
        ),
      ),
    );

    // Check for label and hint text
    expect(find.text('Select Correct Answer'), findsOneWidget);
    expect(find.text('Select answer'), findsOneWidget);
  });

  testWidgets('renders dropdown with selected value', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrashCanDropdown(
            selectedOption: 'Yellow bin',
            onOptionSelected: (_) {},
          ),
        ),
      ),
    );

    // Dropdown should show selected option
    expect(find.text('Yellow bin'), findsOneWidget);
  });

  testWidgets('dropdown contains all 5 options', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrashCanDropdown(
            selectedOption: null,
            onOptionSelected: (_) {},
          ),
        ),
      ),
    );

    // Open the dropdown
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    // All options should appear
    expect(find.text('Yellow bin'), findsOneWidget);
    expect(find.text('Blue bin'), findsOneWidget);
    expect(find.text('Green bin'), findsOneWidget);
    expect(find.text('Red bin'), findsOneWidget);
    expect(find.text('Brown bin'), findsOneWidget);
  });

  testWidgets('calls onOptionSelected when an option is selected', (WidgetTester tester) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrashCanDropdown(
            selectedOption: null,
            onOptionSelected: (value) {
              selected = value;
            },
          ),
        ),
      ),
    );

    // Open dropdown
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    // Tap option "3"
    await tester.tap(find.text('Red bin').last);
    await tester.pumpAndSettle();

    // Confirm callback triggered
    expect(selected, equals('Red bin'));
  });
}
