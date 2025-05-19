import 'package:flutter/material.dart';
import 'package:learnvironment/data/assignment_data.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/games_templates/games_initial_screen.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/firebase/auth_service.dart';
import 'package:provider/provider.dart';

class AssignmentPageTeacher extends StatefulWidget {
  final AssignmentData assignmentData;

  const AssignmentPageTeacher({
    super.key,
    required this.assignmentData,
  });

  @override
  State<AssignmentPageTeacher> createState() => _AssignmentPageTeacherState();
}

class _AssignmentPageTeacherState extends State<AssignmentPageTeacher> {
  late Future<dynamic> _gameDataFuture;

  @override
  void initState() {
    super.initState();
    _gameDataFuture = _fetchGameData();
  }

  Future<void> _deleteAssignment(BuildContext context) async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      await dataService.deleteAssignment(assignmentId: widget.assignmentData.assId);
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/auth_gate');
      }
    } catch (e) {
      print('[deleteSubject] Error deleting subject: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete subject.')),
        );
      }
    }
  }

  void confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: const Text('Are you sure you want to delete this assignment? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/auth_gate');
              await _deleteAssignment(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
                ElevatedButton.icon(
                  onPressed: () => confirmDelete(context),
                  icon: const Icon(Icons.delete),
                  key: Key("delete"),
                  label: const Text('Delete Assignment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
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
                  gameData.gameName,
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
                      child: const Text('Play Game'),
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