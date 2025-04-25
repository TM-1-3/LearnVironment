import 'package:flutter/material.dart';
import 'package:learnvironment/main_pages/widgets/tag.dart';

class GameCard extends StatelessWidget {
  final String imagePath;
  final String gameTitle;
  final List<String> tags;
  final String gameId;
  final Future<void> Function(String gameId) loadGame;

  const GameCard({
    super.key,
    required this.imagePath,
    required this.gameTitle,
    required this.tags,
    required this.gameId,
    required this.loadGame,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GestureDetector(
        key: Key('gameCard_$gameId'),
        onTap: () async => await loadGame(gameId),
        child: Container(
          decoration: BoxDecoration(
            color: Theme
                .of(context)
                .cardColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400,
                blurRadius: 5,
                spreadRadius: 2,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // Center content
                  children: [
                    Center( // Center the game title
                      child: Text(
                        gameTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        List<Widget> tagWidgets = [];
                        for (int i = 0; i < tags.length && i < 3; i++) {
                          tagWidgets.add(TagWidget(tag: tags[i]));
                        }
                        if (tags.length > 3) {
                          tagWidgets.add(
                            TagWidget(tag: '+${tags.length - 3} more'),
                          );
                        }
                        return Center( // Center the tags
                          child: Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: tagWidgets,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}