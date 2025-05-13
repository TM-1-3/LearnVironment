import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/developer/CreateGames/objects/option_object.dart';

void main() {
  group('OptionObject', () {
    late OptionObject optionObject;

    setUp(() {
      optionObject = OptionObject();
    });

    tearDown(() {
      // Dispose of the controllers to prevent memory leaks
      optionObject.option1Controller.dispose();
      optionObject.option2Controller.dispose();
      optionObject.option3Controller.dispose();
      optionObject.option4Controller.dispose();
    });

    test('should return true when all options are empty', () {
      expect(optionObject.isEmpty(), isTrue);
    });

    test('should return true when some options are empty', () {
      optionObject.option1Controller.text = 'Option 1';
      optionObject.option2Controller.text = 'Option 2';
      expect(optionObject.isEmpty(), isTrue);
    });

    test('should return false when all options are filled', () {
      optionObject.option1Controller.text = 'Option 1';
      optionObject.option2Controller.text = 'Option 2';
      optionObject.option3Controller.text = 'Option 3';
      optionObject.option4Controller.text = 'Option 4';
      expect(optionObject.isEmpty(), isFalse);
    });

    test('should dispose all controllers', () {
      final optionObject = OptionObject();
      optionObject.dispose();

      expect(
            () => optionObject.option1Controller.text = "New Value",
        throwsA(isA<FlutterError>()),
      );
      expect(
            () => optionObject.option2Controller.text = "New Value",
        throwsA(isA<FlutterError>()),
      );
      expect(
            () => optionObject.option3Controller.text = "New Value",
        throwsA(isA<FlutterError>()),
      );
      expect(
            () => optionObject.option4Controller.text = "New Value",
        throwsA(isA<FlutterError>()),
      );
    });
  });
}
