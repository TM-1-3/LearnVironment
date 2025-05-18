import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/games_templates/results_page.dart';
import 'package:learnvironment/games_templates/quiz.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/firebase/auth_service.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockAuthService extends Mock implements AuthService {
  late String uid;

  MockAuthService({MockFirebaseAuth? firebaseAuth}) {
    loggedIn = firebaseAuth?.currentUser != null;
    uid = firebaseAuth?.currentUser?.uid ?? '';
    fetchedNotifications = true;
  }

  @override
  Future<String> getUid() async {
    return uid;
  }

  @override
  Stream<User?> get authStateChanges => Stream.value(MockUser());
}

class MockGameData extends Mock implements GameData {
  @override
  String get documentName => 'mock_document';

  @override
  String get gameLogo => 'assets/quizLogo.png';

  @override
  String get gameName => 'EcoMind Challenge';

  @override
  String get gameDescription => 'Quiz About Environment And Sustainability';

  @override
  String get gameBibliography => 'Bibliography';

  @override
  List<String> get tags => ['12+'];

  @override
  String get gameTemplate => 'quiz';

  @override
  Map<String, String> get tips => {
    "What is recycling?": "Tip",
    "Why should we save water?": "Tip",
    "What do trees do for us?": "Tip",
    "How can we reduce waste?": "Tip",
    "What animals live in the ocean?": "Tip",
    "What happens if we pollute rivers?": "Tip",
    "Why is the sun important?": "Tip",
    "How can we help the planet?": "Tip",
    "What is composting?": "Tip",
    "Why should we turn off the lights?": "Tip",
  };

  // Mocking questionsAndOptions
  @override
  Map<String, List<String>> get questionsAndOptions => {
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

  // Mocking correctAnswers
  @override
  Map<String, String> get correctAnswers => {
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
}

class MockDataService extends Mock implements DataService{
  @override
  Future<UserData?> getUserData({required String userId}) {
    return Future.value(UserData(role: '', id: '', username: '', name: '', email: '', birthdate: DateTime(2000, 1, 1, 0, 0, 0, 0, 0), gamesPlayed: [], myGames: [], tClasses: [], stClasses: [], img: ''));
  }
}

void main() {
  group('Quiz App Tests', () {
    late MockGameData quizData;
    late Widget testWidget;
    late MockDataService mockDataService;
    late MockFirebaseAuth mockAuth;

    setUp(() {
      quizData = MockGameData();
      mockDataService = MockDataService();

      mockAuth = MockFirebaseAuth(signedIn: true,
        mockUser: MockUser(
          uid: 'testStudent',
          email: 'test@example.com',
          displayName: 'Test User',
        ),
      );

      testWidget = MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(
            create: (_) => MockAuthService(firebaseAuth: mockAuth),
          ),
          Provider<DataService>(create: (_) => mockDataService),
        ],
        child: MaterialApp(
          home: Quiz(quizData: quizData),
        ),
      );
    });


    testWidgets('Renders start page correctly', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      expect(find.text('EcoMind Challenge'), findsNWidgets(2));
      expect(find.byWidgetPredicate((widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == "assets/quizLogo.png"), findsOneWidget);
      expect(find.byWidgetPredicate((widget) => widget is Text && widget.data == 'EcoMind Challenge' && widget.style?.fontSize == 28 && widget.style?.fontWeight == FontWeight.bold), findsOneWidget);
      expect(find.text('Start Quiz'), findsOneWidget);
    });

    testWidgets('Start Quiz starts the quiz', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.ensureVisible(find.text('Start Quiz'));
      await tester.tap(find.text('Start Quiz'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Question 1'), findsOneWidget);
    });

    testWidgets('Quiz is executed', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.ensureVisible(find.text('Start Quiz'));
      await tester.tap(find.text('Start Quiz'));
      await tester.pumpAndSettle();

      // Simulate answering questions.
      int questionNumber = 1;
      while (questionNumber <= 10) {
        expect(find.text('Question $questionNumber'), findsOneWidget); // Validate question number.
        final answerCards = find.byType(GestureDetector);
        expect(answerCards, findsWidgets); // Ensure answers exist

        // Tap the first answer card
        await tester.tap(answerCards.first);
        await tester.pumpAndSettle(); // Wait for state update
        await tester.pump(Duration(seconds: 3));
        questionNumber++;
      }

      // Verify the results screen.
      await tester.pumpAndSettle();
      expect(find.byType(ResultsPage), findsOneWidget);
    });

    testWidgets('Quiz delivers feedback', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Start quiz and wait for screen to load
      expect(find.text('Start Quiz'), findsOneWidget);
      await tester.tap(find.text('Start Quiz'));
      await tester.pumpAndSettle(); // Wait for quiz screen to load

      // Ensure the first question is visible
      expect(find.text('Question 1'), findsOneWidget);

      final imageFinder = find.byWidgetPredicate((widget) {
        if (widget is Image) {
          final imageAsset = widget.image;
          return (imageAsset is AssetImage) && (imageAsset.assetName == 'assets/right.png' || imageAsset.assetName == 'assets/wrong.png');
        }
        return false;
      });

      // Answer all questions
      for (int i = 1; i <= 10; i++) {
        final answerCards = find.byType(GestureDetector);
        expect(answerCards,findsNWidgets(5)); // Ensure 4 answer options are available
        await tester.tap(answerCards.first); // Simulate answering the first option
        await tester.pumpAndSettle(); // Wait for state update
        expect(imageFinder, findsOneWidget); // Ensure feedback image is shown
        await tester.pump(Duration(seconds: 3)); // Wait for feedback
      }
      await tester.pumpAndSettle();
      expect(find.byType(ResultsPage), findsOneWidget);
      final gestureDetectors = find.byType(GestureDetector);
      expect(gestureDetectors, findsAtLeastNWidgets(2)); // Allow at least 2 buttons
    });
  });
}
