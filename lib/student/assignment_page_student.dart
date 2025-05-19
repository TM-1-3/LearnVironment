import 'package:flutter/material.dart';
import 'package:learnvironment/data/assignment_data.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/games_templates/games_initial_screen.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/firebase/auth_service.dart';
import 'package:provider/provider.dart';

class AssignmentPageStudent extends StatefulWidget {
  final AssignmentData assignmentData;

  const AssignmentPageStudent({
    super.key,
    required this.assignmentData,
  });

  @override
  State<AssignmentPageStudent> createState() => _AssignmentPageStudentState();
}

class _AssignmentPageStudentState extends State<AssignmentPageStudent> {
  late Future<dynamic> _gameDataFuture;

  @override
  void initState() {
    super.initState();
    _gameDataFuture = _fetchGameData();
  }

  Future<dynamic> _fetchGameData() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final gameData = await dataService.getGameData(gameId: widget.assignmentData.gameId);

    if (gameData == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game data not found or invalid.')),
      );
      Navigator.pushReplacementNamed(context, 'auth_gate');
      return null;
    }

    return gameData;
  }

  Future<void> _loadGame(String gameId) async {
    try {
      print('[Games Page] Loading Game');
      final dataService = Provider.of<DataService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);

      final gameData = await dataService.getGameData(gameId: gameId);
      final userId = await authService.getUid();

      if (gameData != null && userId.isNotEmpty && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GamesInitialScreen(gameData: gameData),
          ),
        );
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading game: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignmentData = widget.assignmentData;

    return Scaffold(
      appBar: AppBar(
        title: Text(assignmentData.title),
      ),
      body: FutureBuilder<dynamic>(
        future: _gameDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading game data'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No game data found'));
          }

          final GameData gameData = snapshot.data;

          return SingleChildScrollView(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 180),
                    child: gameData.gameLogo.startsWith('assets/')
                        ? Image.asset(
                      gameData.gameLogo,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                        : Image.network(
                      gameData.gameLogo,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  assignmentData.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  "Game: ${gameData.gameName}",
                ),
                const SizedBox(height: 20),
                Text(
                  "Due Date: ${assignmentData.dueDate}",
                ),
                const SizedBox(height: 40),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                    child: ElevatedButton(
                      onPressed: () => _loadGame(assignmentData.gameId),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Complete Assignment'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}