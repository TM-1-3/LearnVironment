import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  final String imagePath;
  final String gameTitle;
  final List<String> tags;
  final String gameId;
  final Future<void> Function(String gameId) loadGame; // Nullable function

  const GameCard({
    super.key,
    required this.imagePath,
    required this.gameTitle,
    required this.tags,
    required this.gameId,
    required this.loadGame, // Nullable function
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap:  () => loadGame(gameId),
            child: Image.asset(imagePath), // This is the image that you tap
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(gameTitle),
                Row(
                  children: tags
                      .map((tag) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(label: Text(tag)),
                  ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}