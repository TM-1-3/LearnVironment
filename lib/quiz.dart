import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'results_page.dart';  // Import the ResultsPage
import 'game_data.dart';

class Quiz extends StatefulWidget {
  final GameData quizData;  // The quizData passed to this widget

  const Quiz({super.key, required this.quizData});

  @override
  _QuizState createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  final Map<String, List<String>> questionsAndOptions = {
    "What is recycling?": [
      "Reusing materials",
      "Throwing trash",
      "Saving money",
      "Buying new things"
    ],
    "Why should we save water?": [
      "It helps the earth",
      "Water is unlimited",
      "For fun",
      "It doesn't matter"
    ],
    "What do trees do for us?": [
      "Give oxygen",
      "Make noise",
      "Take water",
      "Eat food"
    ],
    "How can we reduce waste?": [
      "Recycle",
      "Burn trash",
      "Throw in rivers",
      "Ignore it"
    ],
    "What animals live in the ocean?": ["Sharks", "Lions", "Elephants", "Cows"],
    "What happens if we pollute rivers?": [
      "Fish die",
      "More water appears",
      "Trees grow faster",
      "It smells better"
    ],
    "Why is the sun important?": [
      "Gives us light",
      "Cools the earth",
      "Makes rain",
      "Creates snow"
    ],
    "How can we help the planet?": [
      "Pick up trash",
      "Cut all trees",
      "Pollute more",
      "Use plastic"
    ],
    "What is composting?": [
      "Turning food waste into soil",
      "Burning paper",
      "Throwing food in the trash",
      "Using plastic"
    ],
    "Why should we turn off the lights?": [
      "Save energy",
      "Break the bulb",
      "Change the color",
      "Make it brighter"
    ]
  };

  final Map<String, String> correctAnswers = {
    "What is recycling?": "Reusing materials",
    "Why should we save water?": "It helps the earth",
    "What do trees do for us?": "Give oxygen",
    "How can we reduce waste?": "Recycle",
    "What animals live in the ocean?": "Sharks",
    "What happens if we pollute rivers?": "Fish die",
    "Why is the sun important?": "Gives us light",
    "How can we help the planet?": "Pick up trash",
    "What is composting?": "Turning food waste into soil",
    "Why should we turn off the lights?": "Save energy"
  };

  late List<String> availableQuestions;
  String currentQuestion = "";
  List<String> currentOptions = [];
  int questionNumber = 0;
  String correctAnswer = "";
  String? selectedAnswer;
  bool? rightAnswer;
  int correctCount = 0;
  int wrongCount = 0;
  bool quizStarted = false;
  bool quizFinished = false;

  @override
  void initState() {
    super.initState();
    availableQuestions = List.from(questionsAndOptions.keys);
  }

  void startQuiz() {
    setState(() {
      quizStarted = true;
      updateQuestionAndOptions();
    });
  }

  void updateQuestionAndOptions() {
    setState(() {
      if (availableQuestions.isNotEmpty) {
        int randomIndex = Random().nextInt(availableQuestions.length);
        currentQuestion = availableQuestions.removeAt(randomIndex);
        currentOptions = List.from(questionsAndOptions[currentQuestion]!);
        currentOptions.shuffle();
        questionNumber++;
        correctAnswer = correctAnswers[currentQuestion]!;
        selectedAnswer = null;
        rightAnswer = null;
      } else {
        // No more questions, finish the quiz
        quizFinished = true;
        // Go to results screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsPage(
              correctCount: correctCount,
              wrongCount: wrongCount,
              questionsCount: 10,
              gameName: widget.quizData.gameName, // Access quizData here
              gameImage: widget.quizData.gameLogo, // Access quizData here
            ),
          ),
        );
      }
    });
  }

  void checkSelectedAnswer(String selected) {
    setState(() {
      selectedAnswer = selected;
      rightAnswer = selected == correctAnswer;
      if (rightAnswer!) {
        correctCount++;
      } else {
        wrongCount++;
      }
    });

    Timer(const Duration(seconds: 2), () {
      updateQuestionAndOptions(); // Move to next question after 2 seconds
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.quizData.gameName)), // Access gameName from quizData
      body: Center(
        child: quizStarted
            ? quizFinished
            ? const SizedBox() // Empty widget since it's handled in the ResultsPage
            : _buildQuizScreen()
            : _buildHomeScreen(),
      ),
    );
  }

  /// 📌 HOME SCREEN
  Widget _buildHomeScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(widget.quizData.gameLogo, width: 200, height: 200), // Access gameLogo from quizData
        const SizedBox(height: 20),
        Text(widget.quizData.gameName, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), // Access gameName from quizData
        const SizedBox(height: 40),
        GestureDetector(
          onTap: startQuiz,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.green,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: Text("Start Quiz", style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  /// 📌 QUIZ SCREEN
  Widget _buildQuizScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(widget.quizData.gameLogo, width: 200, height: 200), // Access gameLogo from quizData
        const SizedBox(height: 20),
        Text("Question $questionNumber", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(currentQuestion, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildClickableCard(currentOptions[0]),
            const SizedBox(width: 20),
            _buildClickableCard(currentOptions[1]),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildClickableCard(currentOptions[2]),
            const SizedBox(width: 20),
            _buildClickableCard(currentOptions[3]),
          ],
        ),
      ],
    );
  }

  Widget _buildClickableCard(String text) {
    bool showIcon = selectedAnswer == text && rightAnswer != null;

    return GestureDetector(
      onTap: () {
        if (selectedAnswer == null) checkSelectedAnswer(text);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 170,
            height: 100,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          if (showIcon)
            Positioned(
              top: 30, // Adjust to center image over the card
              child: Image.asset(
                rightAnswer! ? 'assets/right.png' : 'assets/wrong.png',
                width: 50,
                height: 50,
              ),
            ),
        ],
      ),
    );
  }
}
