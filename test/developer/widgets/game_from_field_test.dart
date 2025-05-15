import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/developer/widgets/game_form_field.dart';

void main() {
  group('GameFormField', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders with the correct label', (tester) async {
      const label = 'Test Label';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameFormField(
              controller: controller,
              label: label,
            ),
          ),
        ),
      );

      expect(find.text(label), findsOneWidget);
    });
  });
}
