import 'package:flutter/material.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:provider/provider.dart';

import 'CreateGames/create_drag.dart';
import 'CreateGames/create_quiz.dart';

class EditGame extends StatefulWidget {
  final String gameId;

  const EditGame({super.key, required this.gameId});

  @override
  State<EditGame> createState() => _EditGameState();
}

class _EditGameState extends State<EditGame> {
  @override
  void initState() {
    super.initState();
    _loadAndNavigate();
  }

  Future<void> _loadAndNavigate() async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final GameData? gameData = await dataService.getGameData(gameId: widget.gameId);

      if (!mounted || gameData == null) return;

      if (gameData.gameTemplate == 'drag') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CreateDragPage(gameData: gameData)),
        );
      } else if (gameData.gameTemplate == 'quiz') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CreateQuizPage(gameData: gameData)),
        );
      } else {
        _showError('Unknown game role: ${gameData.gameTemplate}');
      }
    } catch (e) {
      _showError('Failed to load game: $e');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
