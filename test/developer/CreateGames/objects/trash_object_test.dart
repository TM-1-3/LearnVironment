import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/developer/CreateGames/objects/trash_object.dart';

void main() {
  group('TrashObject', () {
    late TrashObject trashObject;

    setUp(() {
      trashObject = TrashObject();
    });

    tearDown(() {
      trashObject.answerController.dispose();
      trashObject.tipController.dispose();
      trashObject.imageUrlController.dispose();
    });

    test('should return true when all fields are empty', () {
      expect(trashObject.isEmpty(), isTrue);
    });

    test('should return true when answer is empty', () {
      trashObject.tipController.text = 'Some tip';
      trashObject.imageUrlController.text = 'Some tip';

      expect(trashObject.isEmpty(), isTrue);
    });

    test('should return true when tip is empty', () {
      trashObject.answerController.text = 'Some tip';
      trashObject.imageUrlController.text = 'Some tip';

      expect(trashObject.isEmpty(), isTrue);
    });

    test('should return true when image is empty', () {
      trashObject.tipController.text = 'Some tip';
      trashObject.answerController.text = 'Some tip';

      expect(trashObject.isEmpty(), isTrue);
    });

    test('should return false when all fields are filled', () {
      trashObject.tipController.text = 'Some tip';
      trashObject.answerController.text = 'Some tip';
      trashObject.imageUrlController.text = 'Some tip';

      expect(trashObject.isEmpty(), isFalse);
    });

    test('should treat whitespace-only fields as empty', () {
      trashObject.tipController.text = '   ';
      trashObject.answerController.text = '   ';
      trashObject.imageUrlController.text = '   ';

      expect(trashObject.isEmpty(), isTrue);
    });

    test('should throw FlutterError when setting text after dispose', () {
      final trashObject = TrashObject();
      trashObject.dispose();

      expect(() => trashObject.tipController.text = 'Test',
          throwsA(isA<FlutterError>()));

      expect(() => trashObject.answerController.text = 'Tip',
          throwsA(isA<FlutterError>()));

      expect(() => trashObject.imageUrlController.text = 'Option',
          throwsA(isA<FlutterError>()));
    });
  });
}
