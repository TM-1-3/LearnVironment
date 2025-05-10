import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/games_templates/results_page.dart';
import 'package:audioplayers/audioplayers.dart';

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
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    if (widget.quizData.questionsAndOptions == null) {
      throw Exception("Missing quiz data in GameData object.");
    }

    questionsAndOptions = widget.quizData.questionsAndOptions!;
    correctAnswers = widget.quizData.correctAnswers;
    questionsAndOptions.removeWhere((key, value) => value.length < 4);
    availableQuestions = List.from(questionsAndOptions.keys);
    if (availableQuestions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("No Questions Available"),
            content: Text("There are no questions with 4 or more options."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              )
            ],
          ),
        );
      });
    }
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
                questionsCount: questionNumber,
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

  void checkSelectedAnswer(String selected) async {
    setState(() {
      selectedAnswer = selected;
      rightAnswer = selectedAnswer == correctAnswer;
      rightAnswer! ? correctCount++ : wrongCount++;
      if (!rightAnswer!) {
        player.play(AssetSource('wrong_answer.mp3'));
        tipsToAppear.add(widget.quizData.tips[currentQuestion] ?? "No tip available.");
      }
      else {
        player.play(AssetSource('correct_answer.mp3'));
      }
    });
    Timer(const Duration(seconds: 3), () {
      updateQuestionAndOptions(); //Move to next question
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.quizData.gameName),
          leading: IconButton(  // Override the leading property
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/auth_gate');
            },
        ),
      ),
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
            LayoutBuilder(
              builder: (context, constraints) {
                double cardSpacing = 20;
                double totalSpacing = cardSpacing;
                double maxWidthPerCard = (constraints.maxWidth - totalSpacing) / 2;

                return Column(
                  children: [
                    for (int i = 0; i < currentOptions.length; i += 2)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: maxWidthPerCard,
                              child: _buildClickableCard(currentOptions[i]),
                            ),
                            if (i + 1 < currentOptions.length)
                              SizedBox(width: cardSpacing),
                            if (i + 1 < currentOptions.length)
                              SizedBox(
                                width: maxWidthPerCard,
                                child: _buildClickableCard(currentOptions[i + 1]),
                              ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            )
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
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: 170, maxWidth: 200),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
          if (showIcon)
            Positioned(
              top: 15,
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