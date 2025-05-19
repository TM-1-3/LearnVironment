import 'package:flutter/material.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:provider/provider.dart';

class AssignmentCardTeacher extends StatefulWidget {
  final String assignmentTitle;
  final String assignmentId;
  final String gameId;
  final Future<void> Function(String assignmentId) loadAssignment;

  const AssignmentCardTeacher({
    super.key,
    required this.assignmentTitle,
    required this.assignmentId,
    required this.loadAssignment,
    required this.gameId,
  });

  @override
  State<AssignmentCardTeacher> createState() => _AssignmentCardTeacherState();
}

class _AssignmentCardTeacherState extends State<AssignmentCardTeacher> {
  late GameData? _gameData;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final gameData = await dataService.getGameData(gameId: widget.gameId);

    if (gameData == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load game data. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );

        // Delay just a bit so the user sees the SnackBar before navigating
        await Future.delayed(Duration(seconds: 1));

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('auth_gate');
        }
      }
    } else {
      setState(() {
        _gameData = gameData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GestureDetector(
        key: Key('assignmentCard_${widget.assignmentId}'),
        onTap: () async => await widget.loadAssignment(widget.assignmentId),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
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
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 180,
                        ),
                        child: _gameData!.gameLogo.startsWith('assets/')
                            ? Image.asset(
                          _gameData!.gameLogo,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                            : Image.network(
                          _gameData!.gameLogo,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        widget.assignmentTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
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
