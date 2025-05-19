import 'package:flutter/material.dart';
import 'package:learnvironment/data/assignment_data.dart';
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
      body: SingleChildScrollView(
        child: Center(
          child: GestureDetector(
            onTap: () => _loadGame(assignmentData.gameId),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    assignmentData.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
