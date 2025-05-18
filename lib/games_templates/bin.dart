import 'package:flutter/material.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/games_templates/results_page.dart';
import 'package:audioplayers/audioplayers.dart';

class BinScreen extends StatefulWidget {
  final GameData binData;

  const BinScreen({super.key, required this.binData});

  @override
  BinScreenState createState() => BinScreenState();
}

class BinScreenState extends State<BinScreen> {
  // Bin states stored in a Map
  Map<String, bool> binStates = {
    "blue": false,
    "green": false,
    "yellow": false,
    "brown": false,
    "red": false,
  };

  bool showIcon = false;
  bool rightAnswer = true;
  Offset iconPosition = Offset(0, 0);
  int correctCount = 0;
  int wrongCount = 0;
  List<String> tipsToAppear=[];
  late DateTime startTime;
  late Map<String, String> trashItems;
  final player = AudioPlayer();

  late Map<String, String> remainingTrashItems = widget.binData.correctAnswers;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();

    print(widget.binData.correctAnswers);

    //Shuffle objects
    remainingTrashItems = Map.fromEntries(
      remainingTrashItems.entries.toList()..shuffle(),
    );

    //Get 4 original objects
    trashItems = Map.fromEntries(
      remainingTrashItems.entries.take(4),
    );
    trashItems.keys.forEach(remainingTrashItems.remove);
  }

  bool isGameOver() {
    return trashItems.isEmpty && remainingTrashItems.isEmpty;
  }

  Widget getImageWidget(String path, double size) {
    if (path.startsWith('assets/trash')) {
      return Image.asset(path, width: size, height: size);
    } else {
      return Image.network(path, width: size, height: size);
    }
  }

  void removeTrashItem(String item, String bin, Offset position) {
    print('removeTrashItem called with $item -> $bin');
    print('Current trashItems before remove: ${trashItems.keys}');
    print('Current remainingTrashItems: ${remainingTrashItems.keys}');
    setState(() {
      rightAnswer = trashItems[item] == bin;
      rightAnswer ? correctCount++ : wrongCount++;
      if (!rightAnswer) {
        player.play(AssetSource('wrong_answer.mp3'));
        tipsToAppear.add(widget.binData.tips[item] ?? "No tip available.");
      }
      else{
        player.play(AssetSource('correct_answer.mp3'));
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
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        showIcon = false;
      });

      if (isGameOver()) {
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ResultsPage(
                    correctCount: correctCount,
                    wrongCount: wrongCount,
                    questionsCount: 10,
                    gameName: widget.binData.gameName,
                    gameImage: widget.binData.gameLogo,
                    tipsToAppear: tipsToAppear.toSet().toList(),
                    duration: duration,
                    onReplay: () => BinScreen(binData: widget.binData),
                    gameId: widget.binData.documentName,
                  ),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.binData.gameName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/auth_gate');
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;

          // Compute bin dimensions that scale to screen size
          final binHeight = screenHeight * 0.2; // ~15% of screen height
          final binWidth = screenWidth * 0.4;    // ~30% of screen width

          final verticalSpacing = screenHeight * 0.05;

          final totalBinsWidth = 2 * binWidth; // Since there are two bins
          final availableWidthForSpacing = screenWidth - totalBinsWidth; // Remaining space after bins

          final spaceBetweenBins = availableWidthForSpacing / 3;
          final leftMarginYellow = (screenWidth - binWidth) / 2;

          final appBarHeight = AppBar().preferredSize.height;

          final double binHalfWidth = binWidth / 2;
          final double binHalfHeight = binHeight / 2;
          final double offsetXGreen = spaceBetweenBins + binHalfWidth;
          final double offsetXBlue = spaceBetweenBins * 2 + binWidth + binHalfWidth;
          final double offsetXYellow = leftMarginYellow + binHalfWidth;
          final double offsetXBrown = spaceBetweenBins * 2 + binHalfWidth;
          final double offsetXRed = spaceBetweenBins * 2 + binWidth + binHalfWidth;

          final double verticalOffset = appBarHeight + binHalfHeight;

          Offset greenPosition = Offset(offsetXGreen, verticalOffset);
          Offset bluePosition = Offset(offsetXBlue, verticalOffset);
          Offset yellowPosition = Offset(offsetXYellow, verticalOffset + binHeight + verticalSpacing);
          Offset brownPosition = Offset(offsetXBrown, verticalOffset + binHeight * 2 + verticalSpacing * 2);
          Offset redPosition = Offset(offsetXRed, verticalOffset + binHeight * 2 + verticalSpacing * 2);


          return SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          binWidget('green', binHeight, binWidth, greenPosition),
                          binWidget('blue', binHeight, binWidth, bluePosition),
                        ],
                      ),
                      SizedBox(height: verticalSpacing),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          binWidget('yellow', binHeight, binWidth, yellowPosition),
                        ],
                      ),
                      SizedBox(height: verticalSpacing),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          binWidget('brown', binHeight, binWidth, brownPosition),
                          binWidget('red', binHeight, binWidth, redPosition),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: trashItems.keys.map((item) {
                          return Draggable<String>(
                            data: item,
                            feedback: getImageWidget(item, binHeight * 0.6),
                            childWhenDragging: Opacity(
                              opacity: 0.5,
                              child: getImageWidget(item, binHeight * 0.6),
                            ),
                            child: getImageWidget(item, binHeight * 0.6),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // ✅ Show feedback icon if needed
                if (showIcon)
                  Positioned(
                    left: iconPosition.dx,
                    top: iconPosition.dy,
                    child: Image.asset(
                      rightAnswer ? 'assets/right.png' : 'assets/wrong.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget binWidget(String color, double binHeight, double binWidth, Offset binPosition) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (data) {
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
        height: binHeight,
        width: binWidth,
        fit: BoxFit.contain,
      ),
    );
  }
}
