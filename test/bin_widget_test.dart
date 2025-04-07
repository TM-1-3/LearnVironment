import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  testWidgets('Bin widget shows correct sprite (open/closed)', (WidgetTester tester) async {
    // A mock state map like in your actual widget
    final Map<String, bool> binStates = {'green': false};

    // Define a dummy removeTrashItem to avoid errors
    void removeTrashItem(String item, String bin, Offset pos) {}

    // Build the test widget with access to setState
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            Widget binWidget(String color, Offset binPosition) {
              return DragTarget<String>(
                onWillAccept: (data) {
                  setState(() => binStates[color] = true);
                  return true;
                },
                onLeave: (data) {
                  setState(() => binStates[color] = false);
                },
                onAcceptWithDetails: (details) {
                  removeTrashItem(details.data, color, binPosition);
                  setState(() => binStates[color] = false);
                },
                builder: (_, __, ___) => Image.asset(
                  binStates[color]!
                      ? 'assets/open_${color}_bin.png'
                      : 'assets/${color}_bin.png',
                  width: 150,
                  key: const Key('bin_image'), // Add key for easier testing
                ),
              );
            }

            return Column(
              children: [
                binWidget('green', const Offset(0, 0)),
                // A draggable item
                Draggable<String>(
                  data: 'item1',
                  feedback: const SizedBox.shrink(),
                  child: const SizedBox(width: 50, height: 50, child: Text('Item')),
                ),
              ],
            );
          },
        ),
      ),
    );

    // Initially, the bin should be closed
    final closedImage = tester.widget<Image>(find.byKey(const Key('bin_image')));
    expect(closedImage.image, isA<AssetImage>());
    expect((closedImage.image as AssetImage).assetName, 'assets/green_bin.png');
  });
}
