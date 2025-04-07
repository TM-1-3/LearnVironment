import 'package:cloud_firestore/cloud_firestore.dart';

class GameData {
  final String gameLogo;
  final String gameName;
  final String gameDescription;
  final String gameBibliography;
  final List<String> tags;

  // Construtor normal para inicializar os dados manualmente
  GameData({
    required this.gameLogo,
    required this.gameName,
    required this.gameDescription,
    required this.gameBibliography,
    required this.tags,
  });

  // Função para obter os dados do Firestore usando um gameId
  static Future<GameData> fromFirestore(String gameId, FirebaseFirestore firestore) async {
    try {
      // Buscar o documento na coleção 'game' usando o gameId
      DocumentSnapshot snapshot = await firestore.collection('games').doc(gameId).get();

      // Verifica se o documento existe
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;

        // Cria e retorna um objeto GameData com os dados extraídos
        return GameData(
          gameLogo: data['logo'], // 'logo' é o nome do campo no Firestore
          gameName: data['name'], // 'name' é o nome do campo no Firestore
          gameDescription: data['description'], // 'description' no Firestore
          gameBibliography: data['bibliography'], // 'bibliografia' no Firestore
          tags: List<String>.from(data['tags'] ?? []), // 'tags' no Firestore
        );
      } else {
        throw Exception("Jogo não encontrado!");
      }
    } catch (e) {
      throw Exception("Erro ao buscar dados do Firestore: $e");
    }
  }
}

Future<GameData> fetchGameData(String idDataBase, {FirebaseFirestore? firestore}) async {
  try {
    // Use the passed firestore instance or default to FirebaseFirestore.instance
    firestore = firestore ?? FirebaseFirestore.instance;

    // Fetch the game data from Firestore using the fromFirestore method
    return await GameData.fromFirestore(idDataBase, firestore);
  } catch (e) {
    throw Exception("Erro ao carregar dados do jogo: $e");
  }
}

