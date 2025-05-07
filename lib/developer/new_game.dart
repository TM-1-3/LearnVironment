import 'package:flutter/material.dart';
import 'package:learnvironment/developer/CreateGames/create_drag.dart';
import 'package:learnvironment/developer/CreateGames/create_quiz.dart';

class NewGamePage extends StatelessWidget {
  const NewGamePage({super.key});

  static const Map<String, String> gameTypes = {
    'drag': 'assets/widget.png',
    'quiz': 'assets/quizLogo.png',
  };

  void _navigateToGameCreation(BuildContext context, String gameType) {
    switch (gameType) {
      case 'drag':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateDragPage()),
        );
      case 'quiz':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateQuizPage()),
        );
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unknown game type: $gameType')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Template'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: gameTypes.entries.map((entry) {
            final gameType = entry.key;
            final imagePath = entry.value;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: Image.asset(
                  imagePath,
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image),
                ),
                title: Text('Create a $gameType game'),
                onTap: () => _navigateToGameCreation(context, gameType),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
