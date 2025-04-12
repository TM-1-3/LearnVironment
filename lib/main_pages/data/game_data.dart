import 'package:cloud_firestore/cloud_firestore.dart';

class GameData {
  final String gameLogo;
  final String gameName;
  final String gameDescription;
  final String gameBibliography;
  final List<String> tags;
  final String gameTemplate;

  GameData({
    required this.gameLogo,
    required this.gameName,
    required this.gameDescription,
    required this.gameBibliography,
    required this.tags,
    required this.gameTemplate
  });

  static Future<GameData> fromFirestore(String gameId, FirebaseFirestore firestore) async {
    try {
      DocumentSnapshot snapshot = await firestore.collection('games').doc(gameId).get();

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;

        return GameData(
          gameLogo: data['logo'],
          gameName: data['name'],
          gameDescription: data['description'],
          gameBibliography: data['bibliography'],
          tags: List<String>.from(data['tags'] ?? []),
          gameTemplate: data['template']
        );
      } else {
        throw Exception("Game not found!");
      }
    } catch (e) {
      throw Exception("Error getting data from firestore: $e");
    }
  }
}

Future<GameData> fetchGameData(String idDataBase, {FirebaseFirestore? firestore}) async {
  try {
    firestore = firestore ?? FirebaseFirestore.instance;

    return await GameData.fromFirestore(idDataBase, firestore);
  } catch (e) {
    throw Exception("Error Loading data from firestore: $e");
  }
}

