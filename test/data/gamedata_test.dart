import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/game_data.dart';

void main() {
  late GameData gameData;

  setUp(() {
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

    gameData = GameData(
      gameLogo: 'game_logo.png',
      gameName: 'Game Name',
      gameDescription: 'Game Description',
      gameBibliography: 'Game Bibliography',
      tags: ['action', 'adventure'],
      gameTemplate: 'quiz',
      documentName: 'game1',
      questionsAndOptions: questionsAndOptions,
      correctAnswers: correctAnswers,
    );
  });

  test('Test getters of GameData', () {
    expect(gameData.gameLogo, 'game_logo.png');
    expect(gameData.gameName, 'Game Name');
    expect(gameData.gameDescription, 'Game Description');
    expect(gameData.gameBibliography, 'Game Bibliography');
    expect(gameData.tags, ['action', 'adventure']);
    expect(gameData.gameTemplate, 'quiz');
    expect(gameData.documentName, 'game1');
  });

  test('Test toCache function', () {
    final cacheData = gameData.toCache();

    // Ensure fields are correctly serialized
    expect(cacheData['gameLogo'], 'game_logo.png');
    expect(cacheData['gameName'], 'Game Name');
    expect(cacheData['gameDescription'], 'Game Description');
    expect(cacheData['gameBibliography'], 'Game Bibliography');
    expect(jsonDecode(cacheData['tags']!), ['action', 'adventure']);
    expect(cacheData['gameTemplate'], 'quiz');
    expect(cacheData['documentName'], 'game1');

    // Test quiz-specific data
    final questionsAndOptionsCache = jsonDecode(cacheData['questionsAndOptions']!);
    expect(questionsAndOptionsCache['What is recycling?'][0], 'Reusing materials');
    expect(questionsAndOptionsCache['Why should we save water?'][0], 'It helps the earth');

    final correctAnswersCache = jsonDecode(cacheData['correctAnswers']!);
    expect(correctAnswersCache['What is recycling?'], 'Reusing materials');
    expect(correctAnswersCache['Why should we save water?'], 'It helps the earth');
  });

  test('Test fromCache function', () {
    final cacheData = gameData.toCache();
    final deserializedGameData = GameData.fromCache(cacheData);

    // Verify all fields are deserialized correctly
    expect(deserializedGameData.gameLogo, 'game_logo.png');
    expect(deserializedGameData.gameName, 'Game Name');
    expect(deserializedGameData.gameDescription, 'Game Description');
    expect(deserializedGameData.gameBibliography, 'Game Bibliography');
    expect(deserializedGameData.tags, ['action', 'adventure']);
    expect(deserializedGameData.gameTemplate, 'quiz');
    expect(deserializedGameData.documentName, 'game1');

    // Verify quiz-specific fields are deserialized correctly
    expect(deserializedGameData.questionsAndOptions!['What is recycling?']![0], 'Reusing materials');
    expect(deserializedGameData.correctAnswers!['What is recycling?'], 'Reusing materials');
  });

  test('Test fromCache with missing fields (error handling)', () {
    final Map<String, String> incompleteCacheData = {
      'gameLogo': 'game_logo.png',
      'gameName': 'Game Name',
      'gameDescription': 'Game Description',
      'gameBibliography': 'Game Bibliography',
      'tags': jsonEncode(['action', 'adventure']),
      'gameTemplate': 'quiz',
      'documentName': 'game1',
    };

    // Attempt to deserialize with missing quiz data fields (questionsAndOptions, correctAnswers)
    final deserializedGameData = GameData.fromCache(incompleteCacheData);

    // Check that missing fields are handled gracefully (should be null)
    expect(deserializedGameData.questionsAndOptions, null);
    expect(deserializedGameData.correctAnswers, null);
  });

  test('Test toCache with malformed data', () {
    final malformedGameData = GameData(
      gameLogo: 'game_logo.png',
      gameName: 'Game Name',
      gameDescription: 'Game Description',
      gameBibliography: 'Game Bibliography',
      tags: ['action', 'adventure'],
      gameTemplate: 'quiz',
      documentName: 'game1',
      questionsAndOptions: {},
      correctAnswers: {},
    );

    final cacheData = malformedGameData.toCache();

    // Ensure that the empty maps are serialized as empty JSON objects
    expect(cacheData['questionsAndOptions'], '{}');
    expect(cacheData['correctAnswers'], '{}');
  });

  test('Test toCache with empty string values', () {
    final gameDataWithEmptyStrings = GameData(
      gameLogo: '',
      gameName: 'Game Name',
      gameDescription: '',
      gameBibliography: 'Game Bibliography',
      tags: ['action', 'adventure'],
      gameTemplate: 'quiz',
      documentName: 'game1',
      questionsAndOptions: {},
      correctAnswers: {},
    );

    final cacheData = gameDataWithEmptyStrings.toCache();

    // Verify that empty fields are handled correctly and converted as expected
    expect(cacheData['gameLogo'], '');
    expect(cacheData['gameDescription'], '');
    expect(cacheData['questionsAndOptions'], '{}');
    expect(cacheData['correctAnswers'], '{}');
  });
}
