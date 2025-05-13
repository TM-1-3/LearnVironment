import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/developer/CreateGames/objects/question_object.dart';

void main() {
  group('QuestionObject', () {
    late QuestionObject questionObject;

    setUp(() {
      questionObject = QuestionObject();
    });

    tearDown(() {
      questionObject.questionController.dispose();
      questionObject.tipController.dispose();
      questionObject.options.dispose();
    });

    test('should return true when all fields are empty', () {
      expect(questionObject.isEmpty(), isTrue);
    });

    test('should return true when question is empty', () {
      questionObject.tipController.text = 'Some tip';
      questionObject.options.option1Controller.text = 'Option 1';
      questionObject.options.option2Controller.text = 'Option 2';
      questionObject.options.option3Controller.text = 'Option 3';
      questionObject.options.option4Controller.text = 'Option 4';

      expect(questionObject.isEmpty(), isTrue);
    });

    test('should return true when tip is empty', () {
      questionObject.questionController.text = 'Some question';
      questionObject.options.option1Controller.text = 'Option 1';
      questionObject.options.option2Controller.text = 'Option 2';
      questionObject.options.option3Controller.text = 'Option 3';
      questionObject.options.option4Controller.text = 'Option 4';

      expect(questionObject.isEmpty(), isTrue);
    });

    test('should return true when any option is empty', () {
      questionObject.questionController.text = 'Question';
      questionObject.tipController.text = 'Tip';
      questionObject.options.option1Controller.text = 'Option 1';
      questionObject.options.option2Controller.text = 'Option 2';
      questionObject.options.option3Controller.text = 'Option 3';
      questionObject.options.option4Controller.text = ''; // empty

      expect(questionObject.isEmpty(), isTrue);
    });

    test('should return false when all fields are filled', () {
      questionObject.questionController.text = 'Question';
      questionObject.tipController.text = 'Tip';
      questionObject.options.option1Controller.text = 'Option 1';
      questionObject.options.option2Controller.text = 'Option 2';
      questionObject.options.option3Controller.text = 'Option 3';
      questionObject.options.option4Controller.text = 'Option 4';

      expect(questionObject.isEmpty(), isFalse);
    });

    test('should treat whitespace-only fields as empty', () {
      questionObject.questionController.text = '   ';
      questionObject.tipController.text = '   ';
      questionObject.options.option1Controller.text = '   ';
      questionObject.options.option2Controller.text = '   ';
      questionObject.options.option3Controller.text = '   ';
      questionObject.options.option4Controller.text = '   ';

      expect(questionObject.isEmpty(), isTrue);
    });

    test('should throw FlutterError when setting text after dispose', () {
      final questionObject = QuestionObject();
      questionObject.dispose();

      expect(() => questionObject.questionController.text = 'Test',
          throwsA(isA<FlutterError>()));

      expect(() => questionObject.tipController.text = 'Tip',
          throwsA(isA<FlutterError>()));

      expect(() => questionObject.options.option1Controller.text = 'Option',
          throwsA(isA<FlutterError>()));
      expect(
            () => questionObject.options.option2Controller.text = "New Value",
        throwsA(isA<FlutterError>()),
      );
      expect(
            () => questionObject.options.option3Controller.text = "New Value",
        throwsA(isA<FlutterError>()),
      );
      expect(
            () => questionObject.options.option4Controller.text = "New Value",
        throwsA(isA<FlutterError>()),
      );
    });
  });
}
