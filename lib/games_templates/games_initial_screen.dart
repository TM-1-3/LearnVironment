import 'package:flutter/material.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/games_templates/quiz.dart';
import 'package:learnvironment/games_templates/bin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GamesInitialScreen extends StatelessWidget {
  final GameData gameData;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  // Constructor now accepts optional FirebaseAuth and FirebaseFirestore parameters
  GamesInitialScreen({
    super.key,
    required this.gameData,
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        firestore = firestore ?? FirebaseFirestore.instance;

  // Function to update the user's gamesPlayed array
  Future<void> updateUserGamesPlayed(String gameId) async {
    try {
      User? user = firebaseAuth.currentUser;

      if (user == null) {
        throw Exception("No user logged in");
      }

      DocumentReference userDoc = firestore.collection('users').doc(user.uid);
      DocumentSnapshot userSnapshot = await userDoc.get();

      List<dynamic> gamesPlayed = [];

      if (userSnapshot.exists && userSnapshot.data() != null) {
        var data = userSnapshot.data() as Map<String, dynamic>;
        gamesPlayed = List<String>.from(data['gamesPlayed'] ?? []);
      }

      // Remove it if it already exists, then insert at the beginning
      gamesPlayed.remove(gameId);
      gamesPlayed.insert(0, gameId);

      await userDoc.update({'gamesPlayed': gamesPlayed});
    } catch (e) {
      print("Error updating user's gamesPlayed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(gameData.gameName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 🖼️ Image at the Top
            Image.asset(gameData.gameLogo, width: 200, height: 200),

            SizedBox(height: 20),

            /// 📌 Main Text
            Text(
              gameData.gameName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 30),

            /// 🎯 Clickable Card
            GestureDetector(
              onTap: () async {
                // Update the user's gamesPlayed field first
                await updateUserGamesPlayed(gameData.documentName);

                // Action when the card is clicked
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

            /// 📝 First Text
            Text(
              gameData.gameDescription,
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),

            SizedBox(height: 10),

            /// 📝 Second Text
            Text(
              gameData.gameBibliography,
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
