import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/games_templates/results_page.dart';

class Quiz extends StatefulWidget {
  final GameData quizData;
  const Quiz({super.key, required this.quizData});

  @override
  QuizState createState() => QuizState();
}

class QuizState extends State<Quiz> {
  late final Map<String, List<String>> questionsAndOptions;
  late final Map<String, String> correctAnswers;

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
  late DateTime startTime;
  List<String> tipsToAppear=[];

  @override
  void initState() {
    super.initState();
    if (widget.quizData.questionsAndOptions == null || widget.quizData.correctAnswers == null) {
      throw Exception("Missing quiz data in GameData object.");
    }

    questionsAndOptions = widget.quizData.questionsAndOptions!;
    correctAnswers = widget.quizData.correctAnswers!;
    availableQuestions = List.from(questionsAndOptions.keys);
  }

  void startQuiz() {
    setState(() {
      quizStarted = true;
      startTime=DateTime.now();
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
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        // Go to results screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsPage(
                correctCount: correctCount,
                wrongCount: wrongCount,
                questionsCount: 10,
                gameName: widget.quizData.gameName,
                gameImage: widget.quizData.gameLogo,
                tipsToAppear: tipsToAppear,
                duration: duration,
                onReplay: () => Quiz(quizData: widget.quizData)
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
        tipsToAppear.add(widget.quizData.tips[currentQuestion]!);
      }
    });

    Timer(const Duration(seconds: 2), () {
      updateQuestionAndOptions(); //Move to next question
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.quizData.gameName)),
      body: Center(
        child: quizStarted
            ? quizFinished
            ? const SizedBox()
            : _buildQuizScreen()
            : _buildHomeScreen(),
      ),
    );
  }

  Widget _buildHomeScreen() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            Image.asset(widget.quizData.gameLogo, width: 200, height: 200),
            const SizedBox(height: 20),
            Text(
              widget.quizData.gameName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// 📌 QUIZ SCREEN
  Widget _buildQuizScreen() {
    return SingleChildScrollView(
        child: Column(
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
        ));
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
          SizedBox(
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