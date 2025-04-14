import 'package:cloud_firestore/cloud_firestore.dart';

class GameData {
  final String gameLogo;
  final String gameName;
  final String gameDescription;
  final String gameBibliography;
  final List<String> tags;
  final String gameTemplate;
  final String documentName;

  // Optional fields for quiz template
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

      if (!snapshot.exists) {
        throw Exception("Game not found!");
      }

      var data = snapshot.data() as Map<String, dynamic>;

      // Read template type
      String template = data['template'];

      // Initialize optional fields
      Map<String, List<String>>? questionsAndOptions;
      Map<String, String>? correctAnswers;

      // Add fields based on gameTemplate
      if (template == "quiz") {
        try {
          var rawQuestionsAndOptions = Map<String, dynamic>.from(data['questionsAndOptions'] ?? {});
          var rawCorrectAnswers = Map<String, dynamic>.from(data['correctAnswers'] ?? {});

          questionsAndOptions = rawQuestionsAndOptions.map((key, value) {
            return MapEntry(key, List<String>.from(value));
          });

          correctAnswers = rawCorrectAnswers.map((key, value) => MapEntry(key, value.toString()));
        } catch (e) {
          throw Exception("Error parsing quiz fields: $e");
        }
      }

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
    } catch (e) {
      throw Exception("Error getting data from Firestore: $e");
    }
  }
}