import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  static Future<GameData> fromFirestore(String gameId, FirebaseFirestore firestore) async {
    try {
      DocumentSnapshot snapshot = await firestore.collection('games').doc(gameId).get();

      if (!snapshot.exists) throw Exception("Game not found!");

      var data = snapshot.data() as Map<String, dynamic>;
      String template = data['template'];

      Map<String, List<String>>? questionsAndOptions;
      Map<String, String>? correctAnswers;

      if (template == "quiz") {
        try {
          var rawQuestionsAndOptions = Map<String, dynamic>.from(data['questionsAndOptions'] ?? {});
          var rawCorrectAnswers = Map<String, dynamic>.from(data['correctAnswers'] ?? {});

          questionsAndOptions = rawQuestionsAndOptions.map(
                (key, value) => MapEntry(key, List<String>.from(value)),
          );

          correctAnswers = rawCorrectAnswers.map(
                (key, value) => MapEntry(key, value.toString()),
          );
        } catch (e) {
          throw Exception("Error parsing quiz fields: $e");
        }
      }

      if (template == "quiz") {
        return GameData(
          gameLogo: data['logo'],
          gameName: data['name'],
          gameDescription: data['description'],
          gameBibliography: data['bibliography'],
          tags: List<String>.from(data['tags'] ?? []),
          gameTemplate: template,
          documentName: snapshot.id,
          questionsAndOptions: questionsAndOptions,
          correctAnswers: correctAnswers,
        );
      } else {
        return GameData(
          gameLogo: data['logo'],
          gameName: data['name'],
          gameDescription: data['description'],
          gameBibliography: data['bibliography'],
          tags: List<String>.from(data['tags'] ?? []),
          gameTemplate: template,
          documentName: snapshot.id,
        );
      }
    } catch (e) {
      throw Exception("Error getting data from Firestore: $e");
    }
  }

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
      cacheData['questionsAndOptions'] = jsonEncode(questionsAndOptions);
      cacheData['correctAnswers'] = jsonEncode(correctAnswers);
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
      questionsAndOptions = data['questionsAndOptions'] != null
          ? (jsonDecode(data['questionsAndOptions']!) as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, List<String>.from(value)))
          : null;

      correctAnswers = data['correctAnswers'] != null
          ? Map<String, String>.from(jsonDecode(data['correctAnswers']!))
          : null;

      // For quiz games, return the GameData with questionsAndOptions and correctAnswers
      return GameData(
        gameLogo: data['gameLogo'] ?? '',
        gameName: data['gameName'] ?? '',
        gameDescription: data['gameDescription'] ?? '',
        gameBibliography: data['gameBibliography'] ?? '',
        tags: List<String>.from(jsonDecode(data['tags'] ?? '[]')),
        gameTemplate: gameTemplate,
        documentName: data['documentName'] ?? '',
        questionsAndOptions: questionsAndOptions,
        correctAnswers: correctAnswers,
      );
    } else {
      return GameData(
        gameLogo: data['gameLogo'] ?? '',
        gameName: data['gameName'] ?? '',
        gameDescription: data['gameDescription'] ?? '',
        gameBibliography: data['gameBibliography'] ?? '',
        tags: List<String>.from(jsonDecode(data['tags'] ?? '[]')),
        gameTemplate: gameTemplate,
        documentName: data['documentName'] ?? '',
      );
    }
  }
}
