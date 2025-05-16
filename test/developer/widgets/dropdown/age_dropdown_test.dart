import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/developer/widgets/dropdown/age_dropdown.dart';

void main() {
  const testKey = Key('dropdown');
  const ageGroups = ['12+', '10+', '8+', '6+'];

  testWidgets('AgeGroupDropdown displays correct initial value', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AgeGroupDropdown(
          key: testKey,
          selectedAge: '10+',
          onAgeSelected: (_) {},
        ),
      ),
    ));

    final dropdown = find.byKey(testKey);
    expect(dropdown, findsOneWidget);
    expect(find.text('10+'), findsOneWidget);
  });

  testWidgets('AgeGroupDropdown shows correct label text', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AgeGroupDropdown(
          selectedAge: '12+',
          onAgeSelected: (_) {},
        ),
      ),
    ));

    expect(find.text('Select Age Group'), findsOneWidget);
  });

  testWidgets('AgeGroupDropdown contains all age options', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AgeGroupDropdown(
          selectedAge: '12+',
          onAgeSelected: (_) {},
        ),
      ),
    ));

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    for (var age in ageGroups) {
      expect(find.text(age), findsWidgets);
    }
  });

  testWidgets('AgeGroupDropdown calls onAgeSelected with new value', (WidgetTester tester) async {
    String? selected;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AgeGroupDropdown(
          selectedAge: '12+',
          onAgeSelected: (value) {
            selected = value;
          },
        ),
      ),
    ));

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('8+').last);
    await tester.pumpAndSettle();

    expect(selected, equals('8+'));
  });
}
