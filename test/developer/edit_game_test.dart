import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/authentication/auth_gate.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/developer/CreateGames/create_drag.dart';
import 'package:learnvironment/developer/CreateGames/create_quiz.dart';
import 'package:learnvironment/developer/edit_game.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockAuthGate extends AuthGate {
  MockAuthGate({key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Mock AuthGate Screen'),
      ),
    );
  }
}

class MockDataService extends Mock implements DataService {
  @override
  Future<GameData?> getGameData({required String gameId}) async {
    if (gameId == "drag-id") {
      return GameData(
          gameTemplate: 'drag',
          gameDescription: "",
          gameBibliography: "",
          public: false,
          gameName: "",
          gameLogo: "",
          tags: ["Age: 8+"],
          tips: {
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ_ul1wSpSevyEz0TTsJheg5Qeo2hg8L0A3DA&s": "Brown",
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTDx7Z-4u20EXxhklpwJLCnWuXvRaUiLSjxqg&s": "Yellow",
            "https://img.freepik.com/fotos-gratis/fundo-de-gotas-de-agua_23-2148098971.jpg": "Blue",
            "https://media.istockphoto.com/id/1289562025/pt/vetorial/dark-green-background-with-small-touches-christmas-texture-with-vignette-on-the-sides-and.jpg?s=612x612&w=0&k=20&c=xmBy9D9shmOZSWSC4VqcVM7FJYgTAksKflseJVM3Wxo=": "Green",
          },
          correctAnswers: {
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ_ul1wSpSevyEz0TTsJheg5Qeo2hg8L0A3DA&s": "Brown",
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTDx7Z-4u20EXxhklpwJLCnWuXvRaUiLSjxqg&s": "Yellow",
            "https://img.freepik.com/fotos-gratis/fundo-de-gotas-de-agua_23-2148098971.jpg": "Blue",
            "https://media.istockphoto.com/id/1289562025/pt/vetorial/dark-green-background-with-small-touches-christmas-texture-with-vignette-on-the-sides-and.jpg?s=612x612&w=0&k=20&c=xmBy9D9shmOZSWSC4VqcVM7FJYgTAksKflseJVM3Wxo=": "Green",
          },
          documentName: 'drag-id'
      );
    } else if (gameId == "quiz-id") {
      return GameData(
          gameTemplate: 'quiz',
          gameDescription: "",
          gameBibliography: "",
          public: false,
          gameName: "",
          gameLogo: "",
          tags: ["Age: 8+"],
          tips: {
            "What is recycling?": "Reusing materials",
            "Why should we save water?": "It helps the earth",
            "What is recycling?1": "Reusing materials",
            "Why should we save water?2": "It helps the earth",
            "Why should we save water?3": "It helps the earth",
          },
          correctAnswers: {
            "What is recycling?": "Reusing materials",
            "Why should we save water?": "It helps the earth",
            "What is recycling?1": "Reusing materials",
            "Why should we save water?2": "It helps the earth",
            "Why should we save water?3": "It helps the earth",
          },
          documentName: 'quiz-id',
          questionsAndOptions: {
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
            "What is recycling?1": [
              "Reusing materials",
              "Throwing trash",
              "Saving money",
              "Buying new things"
            ],
            "Why should we save water?2": [
              "It helps the earth",
              "Water is unlimited",
              "For fun",
              "It doesn't matter"
            ],
            "Why should we save water?3": [
              "It helps the earth",
              "Water is unlimited",
              "For fun",
              "It doesn't matter"
            ],
          }
      );
    } else {
      print("Hello");
      throw Exception("Network Error");
    }
  }
}

void main() {
  late MockDataService mockDataService;

  setUp(() {
    mockDataService = MockDataService();
  });

  Widget createTestWidget(String gameId) {
    return MaterialApp(
      home: Provider<DataService>.value(
        value: mockDataService,
        child: EditGame(gameId: gameId),
      ),
      routes: {
        '/auth_gate': (context) => MockAuthGate(),
      },
    );
  }

  testWidgets('Navigates to CreateDragPage when gameTemplate is "drag"', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget('drag-id'));

    await tester.pumpAndSettle();

    expect(find.byType(CreateDragPage), findsOneWidget);
  });

  testWidgets('Navigates to CreateQuizPage when gameTemplate is "quiz"', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget('quiz-id'));

    await tester.pumpAndSettle();

    expect(find.byType(CreateQuizPage), findsOneWidget);
  });

  testWidgets('Shows error dialog when dataService throws', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget('fail-id'));

    await tester.pumpAndSettle();

    expect(find.textContaining('Failed to load game'), findsOneWidget);
    expect(find.byType(MockAuthGate), findsOneWidget);
  });
}
