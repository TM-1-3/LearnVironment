import 'package:flutter/material.dart';

class ResultsPage extends StatelessWidget {
  final int questionsCount;
  final int correctCount;
  final int wrongCount;
  final String gameName;
  final String gameImage;
  final List<String> tipsToAppear;
  final Duration duration;

  final Widget Function() onReplay;

  const ResultsPage({
    super.key,
    required this.questionsCount,
    required this.correctCount,
    required this.wrongCount,
    required this.gameName,
    required this.gameImage,
    required this.tipsToAppear,
    required this.duration,
    required this.onReplay,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$gameName Results"),
        leading: IconButton(  // Override the leading property
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/auth_gate');
          },
        ),
      ),
      body: SingleChildScrollView(  // Wrap the content in a SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 20),
              Text("🕒 Time Taken: ${duration.inMinutes}:${duration.inSeconds % 60}", style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
              const SizedBox(height: 20),
              ExpansionTile(
                title: Row(
                  children: [
                    const Icon(Icons.feedback_outlined, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      "Feedback",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                childrenPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                initiallyExpanded: false,
                children: [
                  if (wrongCount > 0 && tipsToAppear.isNotEmpty) ...[
                    ...tipsToAppear.map(
                          (tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("• ",
                                style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(
                                tip,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else
                    const Text(
                    "Great Job!! Keep up the Good Work!!",
                    style: TextStyle(fontSize: 16),
                    ),
                ],
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => onReplay()), // Navigate to HomePage
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    child: Text("Play Again", style: TextStyle(fontSize: 20, color: Colors.grey)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/auth_gate');
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    child: Text("Exit", style: TextStyle(fontSize: 20, color: Colors.grey)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}