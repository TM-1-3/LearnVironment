import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Mock data
  late Map<String, String> trashItems;
  late Map<String, String> remainingTrashItems;
  late int correctCount;
  late int wrongCount;
  late Offset iconPosition;
  late bool showIcon;
  late bool rightAnswer;

  // Test setup to initialize the required state
  setUp(() {
    trashItems = {
      'item1': 'bin1',
      'item2': 'bin2',
    };
    remainingTrashItems = {
      'item3':'bin3',
    };
    correctCount = 0;
    wrongCount = 0;
    iconPosition = Offset.zero;
    showIcon = false;
    rightAnswer = false;
  });

  // The actual method being tested (modified without setState)
  void removeTrashItem(String item, String bin, Offset position) {
    // Directly update the state variables (simulate setState)
    rightAnswer = trashItems[item] == bin;
    if (rightAnswer) {
      correctCount++;
    } else {
      wrongCount++;
    }
    iconPosition = position;
    showIcon = true;

    trashItems.remove(item);

    if (remainingTrashItems.isNotEmpty) {
      // Get the first available item from the remainingTrashItems
      String nextItem = remainingTrashItems.keys.first;
      trashItems[nextItem] = remainingTrashItems[nextItem]!;
      remainingTrashItems.remove(nextItem);
    }
  }

  // Test the removeTrashItem function
  test('Test removeTrashItem correct placement', () {
    // Simulate placing item in the correct bin
    String item = 'item1';
    String bin = 'bin1';
    Offset position = Offset(100, 100);

    removeTrashItem(item, bin, position);

    // Check that the item was removed
    expect(trashItems.containsKey(item), isFalse);

    // Verify correct count increased
    expect(correctCount, 1);

    // Check that remainingTrashItems were updated correctly
    expect(remainingTrashItems.containsKey('item3'), isFalse);
    expect(trashItems.containsKey('item3'), isTrue);

    // Check position and visibility of icon
    expect(iconPosition, position);
    expect(showIcon, true);

    // Check that rightAnswer is true
    expect(rightAnswer, isTrue);
  });

  test('Test removeTrashItem incorrect placement', () {
    // Simulate placing item in the incorrect bin
    String item = 'item1';
    String bin = 'bin2';
    Offset position = Offset(200, 200);

    removeTrashItem(item, bin, position);

    // Check that the item was removed
    expect(trashItems.containsKey(item), isFalse);

    // Verify wrong count increased
    expect(wrongCount, 1);

    // Check that remainingTrashItems were updated correctly
    expect(trashItems.containsKey('item1'), isFalse);
    expect(remainingTrashItems.containsKey('item3'), isFalse);
    expect(trashItems.containsKey('item3'), isTrue);

    // Check position and visibility of icon
    expect(iconPosition, position);
    expect(showIcon, true);

    // Check that rightAnswer is false
    expect(rightAnswer, isFalse);
  });

  test('Test removeTrashItem when remaining items are empty', () {
    // Fill trashItems to simulate the state where there are no remaining trash items
    trashItems = {
      'item1' : 'bin1'
    };
    remainingTrashItems.clear();

    String item = 'item1';
    String bin = 'bin1';
    Offset position = Offset(300, 300);

    // Simulate placing item in the correct bin
    removeTrashItem(item, bin, position);

    // Check that no new items were added
    expect(trashItems.isEmpty, isTrue);

    // Verify correct count has increased
    expect(correctCount, 1);
    expect(wrongCount, 0);
  });
}
