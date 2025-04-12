import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/data/user_data.dart';

class FirestoreService {
  final FirebaseFirestore firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getAllGames() async {
    try {
      final querySnapshot = await firestore.collection('games').get();

      return querySnapshot.docs.map((doc) {
        return {
          'imagePath': doc.get('logo') ?? 'assets/placeholder.png',
          'gameTitle': doc.get('name') ?? 'Default Game Title',
          'tags': List<String>.from(doc.get('tags') ?? []),
          'gameId': doc.id,
        };
      }).toList();
    } catch (e) {
      print('Error getting games: $e');
      return [];
    }
  }

  Future<GameData> fetchGameData(String idDataBase) async {
    try {
      return await GameData.fromFirestore(idDataBase, firestore);
    } catch (e) {
      throw Exception("Error loading data from Firestore: $e");
    }
  }

  Future<UserData> fetchUserData(String userId) async {
    try {
      return await UserData.fromFirestore(userId, firestore);
    } catch (e) {
      throw Exception("Error loading data from Firestore: $e");
    }
  }
}