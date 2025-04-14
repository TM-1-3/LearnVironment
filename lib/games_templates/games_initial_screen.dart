import 'package:flutter/material.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/games_templates/quiz.dart';
import 'package:learnvironment/games_templates/bin.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/auth_service.dart';  // Import AuthService
import 'package:provider/provider.dart'; // Import Provider

class GamesInitialScreen extends StatelessWidget {
  final GameData gameData;

  // Constructor no longer requires DataService as a parameter
  GamesInitialScreen({
    super.key,
    required this.gameData,
  });

  // Function to update the user's gamesPlayed array via DataService
  Future<void> updateUserGamesPlayed(String userId, String gameId, DataService dataService) async {
    try {
      await dataService.updateUserGamesPlayed(userId, gameId);
      print('[GamesInitialScreen] Updated gamesPlayed for the user');
    } catch (e) {
      print('[GamesInitialScreen] Error updating gamesPlayed: $e');
      throw Exception("Error updating user's gamesPlayed");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the AuthService from the Provider
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(title: Text(gameData.gameName)),
      body: FutureBuilder<String?>(
        // Use FutureBuilder to wait for the userId from AuthService
        future: authService.getUid(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Loading state
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Error state
          }

          // Get userId once the Future is complete
          final String userId = snapshot.data ?? '';

          // If no userId is found, return a message
          if (userId.isEmpty) {
            return Center(child: Text('No user is currently logged in.'));
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(gameData.gameLogo, width: 200, height: 200),
                SizedBox(height: 20),
                Text(
                  gameData.gameName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: () async {
                    final dataService = Provider.of<DataService>(context, listen: false);
                    await updateUserGamesPlayed(userId, gameData.documentName, dataService);

                    // Action when the card is clicked based on game template
                    if (gameData.gameTemplate == "drag") {
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BinScreen(binData: gameData),
                          ),
                        );
                      }
                    } else if (gameData.gameTemplate == "quiz") {
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Quiz(quizData: gameData),
                          ),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error Game Data Corrupted.')),
                        );
                      }
                    }
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      child: Text("Play", style: TextStyle(fontSize: 20, color: Colors.grey)),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Description:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        gameData.gameDescription,
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Bibliography:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        gameData.gameBibliography,
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    ],
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
