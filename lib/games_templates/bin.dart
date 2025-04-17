import 'package:flutter/material.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/games_templates/results_page.dart';
import 'package:learnvironment/main_pages/games_page.dart';

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

  // Trash items mapped to their correct bin
  Map<String, String> trashItems = {
    "trash1": "brown",
    "trash2": "red",
    "trash3": "yellow",
    "trash4": "blue",
  };

  Map<String, String> remainingTrashItems = {
    "trash5": "green",
    "trash6": "blue",
    "trash7": "red",
    "trash8": "green",
    "trash9": "yellow",
    "trash10": "brown",
  };

  @override
  void initState() {
    super.initState();
    startTime=DateTime.now();
  }

  bool isGameOver() {
    return trashItems.isEmpty && remainingTrashItems.isEmpty;
  }

  void removeTrashItem(String item, String bin, Offset position) {
    setState(() {
      // Check if the item was placed in the correct bin
      rightAnswer = trashItems[item] == bin;
      if (rightAnswer) {
        correctCount++;
      } else {
        wrongCount++;
        tipsToAppear.add(widget.binData.tips[item]!);
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
                    onReplay: () => BinScreen(binData: widget.binData)
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
      appBar: AppBar(title: Text(widget.binData.gameName,),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GamesPage()),
              );
            },
          )),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate positions based on layout constraints
          Offset greenPosition = Offset(constraints.maxWidth * 0.2 + 35, constraints.maxHeight * 0.2);
          Offset bluePosition = Offset(constraints.maxWidth * 0.6 + 65, constraints.maxHeight * 0.2);
          Offset yellowPosition = Offset(constraints.maxWidth * 0.4 + 50, constraints.maxHeight * 0.4 + 50);
          Offset brownPosition = Offset(constraints.maxWidth * 0.2 + 35, constraints.maxHeight * 0.6 + 100);
          Offset redPosition = Offset(constraints.maxWidth * 0.6 + 65, constraints.maxHeight * 0.6 + 100);

          return SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        // First Row: 2 Bins
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            binWidget('green', greenPosition),
                            binWidget('blue', bluePosition),
                          ],
                        ),
                        // Second Row: 1 Bin
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            binWidget('yellow', yellowPosition),
                          ],
                        ),
                        // Third Row: 2 Bins
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            binWidget('brown', brownPosition),
                            binWidget('red', redPosition),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            alignment: WrapAlignment.center,
                            children: trashItems.keys.map((item) {
                              return Draggable<String>(
                                data: item,
                                feedback: Image.asset('assets/$item.png', width: 80, height: 80),
                                childWhenDragging: Opacity(
                                  opacity: 0.5,
                                  child: Image.asset('assets/$item.png', width: 80, height: 80),
                                ),
                                child: Image.asset('assets/$item.png', width: 80, height: 80),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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

  Widget binWidget(String color, Offset binPosition) {
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
        binStates[color]! ? 'assets/open_${color}_bin.png' : 'assets/${color}_bin.png',
        width: 150,
      ),
    );
  }
}