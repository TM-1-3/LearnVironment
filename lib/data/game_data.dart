import 'dart:convert';

class GameData {
  final String gameLogo;
  final String gameName;
  final String gameDescription;
  final String gameBibliography;
  final List<String> tags;
  final String gameTemplate;
  final String documentName;
  final Map<String, String> tips;
  final Map<String, String> correctAnswers;

  // These fields will only exist for quizzes
  final Map<String, List<String>>? questionsAndOptions;

  GameData({
    required this.gameLogo,
    required this.gameName,
    required this.gameDescription,
    required this.gameBibliography,
    required this.tags,
    required this.gameTemplate,
    required this.documentName,
    this.questionsAndOptions,
    required this.correctAnswers,
    required this.tips,
  });

  // Convert to cache format: Only serialize quiz fields if applicable
  Map<String, String> toCache() {
    final Map<String, String> cacheData = {
      'gameLogo': gameLogo,
      'gameName': gameName,
      'gameDescription': gameDescription,
      'gameBibliography': gameBibliography,
      'tags': jsonEncode(tags),
      'gameTemplate': gameTemplate,
      'documentName': documentName,
      'tips' : jsonEncode(tips),
      'correctAnswers' : jsonEncode(correctAnswers)
    };

    // Add quiz-specific fields only if it's a quiz game
    if (gameTemplate == "quiz") {
      try {
        cacheData['questionsAndOptions'] = jsonEncode(questionsAndOptions);
      } catch (e) {
        print("Error serializing quiz data to cache: $e");
      }
    }
    return cacheData;
  }

  // Deserialize from cache
  factory GameData.fromCache(Map<String, String> data) {
    String gameTemplate = data['gameTemplate'] ?? '';
    Map<String, String> tips = {};
    Map<String, String> correctAnswers = {};

    try {
      tips = Map<String, String>.from(jsonDecode(data['tips']!));
      correctAnswers = Map<String, String>.from(jsonDecode(data['correctAnswers']!));
    }catch (e) {
      print("Error Getting Tips or Answers.");
    }

    // Declare quiz-specific fields
    Map<String, List<String>>? questionsAndOptions;

    // Only deserialize quiz fields if it's a "quiz" game
    if (gameTemplate == "quiz") {
      try {
        questionsAndOptions = data['questionsAndOptions'] != null
            ? (jsonDecode(data['questionsAndOptions']!) as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, List<String>.from(value)))
            : null;
      } catch (e) {
        print("Error deserializing quiz data from cache: $e");
      }
    }

    // Handle non-quiz games or quiz games
    if (gameTemplate == "quiz") {
      return GameData(
        gameLogo: data['gameLogo'] ?? 'default_logo.png',
        gameName: data['gameName'] ?? 'Unnamed Game',
        gameDescription: data['gameDescription'] ?? 'No description available.',
        gameBibliography: data['gameBibliography'] ?? 'No bibliography available.',
        tags: List<String>.from(jsonDecode(data['tags'] ?? '[]')),
        gameTemplate: gameTemplate,
        documentName: data['documentName'] ?? '',
        questionsAndOptions: questionsAndOptions,
        correctAnswers: correctAnswers,
        tips: tips,
      );
    } else {
      return GameData(
        gameLogo: data['gameLogo'] ?? 'default_logo.png',
        gameName: data['gameName'] ?? 'Unnamed Game',
        gameDescription: data['gameDescription'] ?? 'No description available.',
        gameBibliography: data['gameBibliography'] ?? 'No bibliography available.',
        tags: List<String>.from(jsonDecode(data['tags'] ?? '[]')),
        gameTemplate: gameTemplate,
        documentName: data['documentName'] ?? '',
        correctAnswers: correctAnswers,
        tips: tips,
      );
    }
  }
}
