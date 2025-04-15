import 'dart:convert';

class GameData {
  final String gameLogo;
  final String gameName;
  final String gameDescription;
  final String gameBibliography;
  final List<String> tags;
  final String gameTemplate;
  final String documentName;

  // These fields will only exist for quizzes
  final Map<String, List<String>>? questionsAndOptions;
  final Map<String, String>? correctAnswers;

  GameData({
    required this.gameLogo,
    required this.gameName,
    required this.gameDescription,
    required this.gameBibliography,
    required this.tags,
    required this.gameTemplate,
    required this.documentName,
    this.questionsAndOptions,
    this.correctAnswers,
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
    };

    // Add quiz-specific fields only if it's a quiz game
    if (gameTemplate == "quiz") {
      try {
        cacheData['questionsAndOptions'] = jsonEncode(questionsAndOptions);
        cacheData['correctAnswers'] = jsonEncode(correctAnswers);
      } catch (e) {
        print("Error serializing quiz data to cache: $e");
      }
    }
    return cacheData;
  }

  // Deserialize from cache
  factory GameData.fromCache(Map<String, String> data) {
    String gameTemplate = data['gameTemplate'] ?? '';

    // Declare quiz-specific fields
    Map<String, List<String>>? questionsAndOptions;
    Map<String, String>? correctAnswers;

    // Only deserialize quiz fields if it's a "quiz" game
    if (gameTemplate == "quiz") {
      try {
        questionsAndOptions = data['questionsAndOptions'] != null
            ? (jsonDecode(data['questionsAndOptions']!) as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, List<String>.from(value)))
            : null;

        correctAnswers = data['correctAnswers'] != null
            ? Map<String, String>.from(jsonDecode(data['correctAnswers']!))
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
      );
    }
  }
}
