import 'package:flutter/material.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/games_templates/games_initial_screen.dart';
import 'package:learnvironment/main_pages/widgets/game_card.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:provider/provider.dart';

class StudentStatsPage extends StatefulWidget {
  const StudentStatsPage({super.key});

  @override
  StudentStatsPageState createState() => StudentStatsPageState();
}

class StudentStatsPageState extends State<StudentStatsPage> {
  List<Map<String, dynamic>> games = [];

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);

      final uid = await authService.getUid();
      final fetchedGames = await dataService.getPlayedGames(uid);

      if (fetchedGames.isNotEmpty) {
        setState(() {
          games = fetchedGames;
        });
      } else {
        print('[STATS] No games played yet.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading games: $e')),
        );
      }
      print('[STATS ERROR] $e');
    }
  }

  Future<void> _loadGame(String gameId) async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);

      // Ensure you check for null or handle this properly
      GameData? gameData = await dataService.getGameData(gameId);

      if (gameData != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GamesInitialScreen(gameData: gameData),
          ),
        );
      } else {
        throw 'Game data not found';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading game: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Recently Played',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    var mainAxisExtent = 600.0;
                    if (constraints.maxWidth <= 600) {
                      mainAxisExtent = constraints.maxWidth - 40;
                    } else if (constraints.maxWidth <= 1000) {
                      mainAxisExtent = 650;
                    } else if (constraints.maxWidth <= 2000) {
                      mainAxisExtent = 1050;
                    } else {
                      mainAxisExtent = 1500;
                    }
                    return games.isNotEmpty
                        ? GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        mainAxisExtent: mainAxisExtent, // Fixed height for items
                      ),
                      itemCount: games.length,
                      itemBuilder: (context, index) {
                        final game = games[index];
                        return GameCard(
                          imagePath: game['imagePath'],
                          gameTitle: game['gameTitle'],
                          tags: List<String>.from(game['tags']),
                          gameId: game['gameId'],
                          loadGame: _loadGame,
                        );
                      },
                    )
                        : const Center(
                      child: Text('No games have been played yet!'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
