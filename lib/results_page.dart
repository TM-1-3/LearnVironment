import 'package:flutter/material.dart';
import 'package:learnvironment/main_pages/games_page.dart';

class ResultsPage extends StatelessWidget {
  final int questionsCount;
  final int correctCount;
  final int wrongCount;
  final String gameName;
  final String gameImage;

  const ResultsPage({
    super.key,
    required this.questionsCount,
    required this.correctCount,
    required this.wrongCount,
    required this.gameName,
    required this.gameImage,
  });
  @override
  Widget build(BuildContext context) {
    String feedback;
    if (wrongCount>0){
      feedback="Revise the Materials";
    }
    else{
      feedback="Great Job!! Keep up the good work";
    }
    return Scaffold(
      appBar: AppBar(title: Text("$gameName Results")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(gameImage, width: 200, height: 200),
            const SizedBox(height: 40),
            const Text("Game Completed!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text("✅ Correct Answers: $correctCount", style: const TextStyle(fontSize: 20, color: Colors.green)),
            const SizedBox(height: 10),
            Text("❌ Wrong Answers: $wrongCount", style: const TextStyle(fontSize: 20, color: Colors.red)),
            const SizedBox(height:40),
            Text(
              "Feedback:",
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            Text(
              feedback,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => GamesPage()), // Navigate to HomePage
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  child: Text("Back to Games Page", style: TextStyle(fontSize: 20, color: Colors.grey)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
