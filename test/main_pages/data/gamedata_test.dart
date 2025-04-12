import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:learnvironment/main_pages/data/game_data.dart';

void main() {
  late FirebaseFirestore firestore;

  setUp(() {
    // Initialize fake Firestore before each test
    firestore = FakeFirebaseFirestore();
  });

  test('GameData handles quizzes', () async {
    // Sample quiz-specific fields
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

    //Update file
    await firestore.collection('games').doc('game1').set({
      'logo': 'game_logo.png',
      'name': 'Game Name',
      'description': 'Game Description',
      'bibliography': 'Game Bibliography',
      'tags': ['action', 'adventure'],
      'template': 'quiz',
      'questionsAndOptions': questionsAndOptions,
      'correctAnswers': correctAnswers,
    });

    //Fetch
    GameData gameData = await GameData.fromFirestore('game1', firestore);

    expect(gameData.gameLogo, 'game_logo.png');
    expect(gameData.gameName, 'Game Name');
    expect(gameData.gameDescription, 'Game Description');
    expect(gameData.gameBibliography, 'Game Bibliography');
    expect(gameData.tags, ['action', 'adventure']);
    expect(gameData.gameTemplate, 'quiz');
    expect(gameData.questionsAndOptions, questionsAndOptions);
    expect(gameData.correctAnswers, correctAnswers);
  });

  test('Game not found exception', () async {
    try {
      // Attempt to fetch a game that does not exist
      await GameData.fromFirestore('non_existing_game', firestore);
      fail('Expected an exception to be thrown');
    } catch (e) {
      // Verify that the exception is thrown
      expect(e.toString(), contains('Game not found!'));
    }
  });

  test('fetchGameData should return valid GameData', () async {
    // Set up the mock Firestore data
    await firestore.collection('games').doc('game2').set({
      'logo': 'game_logo.png',
      'name': 'Game 2',
      'description': 'Game 2 Description',
      'bibliography': 'Game 2 Bibliography',
      'tags': ['strategy', 'simulation'],
      'template' : 'drag'
    });

    // Call the fetchGameData function
    GameData gameData = await fetchGameData('game2', firestore: firestore);

    // Verify that the fetched data is correct
    expect(gameData.gameLogo, 'game_logo.png');
    expect(gameData.gameName, 'Game 2');
    expect(gameData.gameDescription, 'Game 2 Description');
    expect(gameData.gameBibliography, 'Game 2 Bibliography');
    expect(gameData.tags, ['strategy', 'simulation']);
    expect(gameData.gameTemplate, 'drag');
  });

  test('fetchGameData should throw exception if error occurs', () async {
    // Mock an error by calling a non-existent document
    try {
      await fetchGameData('non_existing_game');
      fail('Expected an exception to be thrown');
    } catch (e) {
      // Ensure that the exception message is what we expect
      expect(e.toString(), contains('Error loading data from Firestore'));
    }
  });
}