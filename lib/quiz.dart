import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class Quiz extends StatefulWidget {
  const Quiz({super.key});

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
    //updateQuestionAndOptions(); // Set a question on start
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
        //currentQuestion = "No more questions!";
        //currentOptions = [];
        //correctAnswer = "";
        quizFinished = true;
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

    Timer(Duration(seconds: 2), () {
      updateQuestionAndOptions(); // Move to next question after 1 second
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quiz")),
      body: Center(
        child: quizStarted
            ? quizFinished
            ? _buildResultsScreen()
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
        Image.asset('assets/quizLogo.png', width: 200, height: 200), // 🖼️ Logo at the top
        SizedBox(height: 20),
        Text("Sustainability Quiz", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        SizedBox(height: 40),
        GestureDetector(
          onTap: startQuiz,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.green,
            child: Padding(
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
        Image.asset('assets/quizLogo.png', width: 200, height: 200), // 🖼️ Image on top
        SizedBox(height: 20),
        Text("Question $questionNumber", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 30),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(currentQuestion, style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
          ),
        ),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildClickableCard(currentOptions[0]),
            SizedBox(width: 20),
            _buildClickableCard(currentOptions[1]),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildClickableCard(currentOptions[2]),
            SizedBox(width: 20),
            _buildClickableCard(currentOptions[3]),
          ],
        ),
      ],
    );
  }

  /// 📌 RESULTS SCREEN
  Widget _buildResultsScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/quizLogo.png', width: 200, height: 200), // 🖼️ Image on top
        SizedBox(height: 20),
        Text("Quiz Completed!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        Text("✅ Correct Answers: $correctCount", style: TextStyle(fontSize: 20, color: Colors.green)),
        SizedBox(height: 10),
        Text("❌ Wrong Answers: $wrongCount", style: TextStyle(fontSize: 20, color: Colors.red)),
        SizedBox(height: 40),

        // 🔹 Clickable card to return to home
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.green,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: Text("Go Back to Home Page", style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
          ),
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
                  padding: EdgeInsets.all(20),
                  child: Text(
                    text,
                    style: TextStyle(fontSize: 18),
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
