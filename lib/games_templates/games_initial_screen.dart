import 'package:flutter/material.dart';
import '../quiz.dart';
import '../main_pages/game_data.dart';

class GamesInitialScreen extends StatelessWidget {
  final GameData gameData;

  const GamesInitialScreen({super.key,required this.gameData});

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
              onTap: () {
                // Action when the card is clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Quiz(quizData : gameData)),
                );
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