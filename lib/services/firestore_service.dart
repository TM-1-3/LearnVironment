import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/data/user_data.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getAllGames() async {
    try {
      final querySnapshot = await _firestore.collection('games').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'imagePath': data['logo'] ?? 'assets/placeholder.png',
          'gameTitle': data['name'] ?? 'Default Game Title',
          'tags': List<String>.from(data['tags'] ?? []),
          'gameId': doc.id,
        };
      }).toList();
    } catch (e, stackTrace) {
      debugPrint('Error getting games: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPlayedGames(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        debugPrint("Error: No user found for UID: $uid");
        return [];
      }

      final data = userDoc.data();
      if (data?.containsKey('gamesPlayed') ?? false) {
        final games = data!['gamesPlayed'];

        if (games is List) {
          final gameIds = games.whereType<String>().toList(); // Ensure it's a list of strings
          if (gameIds.isEmpty) return [];

          final querySnapshot = await _firestore
              .collection('games')
              .where(FieldPath.documentId, whereIn: gameIds)
              .get();

          return querySnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'imagePath': data['logo'] ?? 'assets/placeholder.png',
              'gameTitle': data['name'] ?? 'Default Game Title',
              'tags': List<String>.from(data['tags'] ?? []),
              'gameId': doc.id,
            };
          }).toList();
        } else {
          debugPrint("Error: 'gamesPlayed' is not a List.");
          return [];
        }
      } else {
        debugPrint("Error: No 'gamesPlayed' field found for user.");
        return [];
      }
    } catch (e, stackTrace) {
      debugPrint("Error fetching user played games: $e\n$stackTrace");
      return [];
    }
  }

  // Update the user's gamesPlayed list both in Firestore and the cache
  Future<void> updateUserGamesPlayed(String uid, String gameId) async {
    final userDoc = _firestore.collection('users').doc(uid);
    final userSnapshot = await userDoc.get();

    List<String> gamesPlayed = [];

    if (userSnapshot.exists && userSnapshot.data() != null) {
      final data = userSnapshot.data()!;
      gamesPlayed = List<String>.from(data['gamesPlayed'] ?? []);
    }

    gamesPlayed.remove(gameId);
    gamesPlayed.insert(0, gameId);

    try {
      await userDoc.update({'gamesPlayed': gamesPlayed});
      print('[FirestoreService] Updated gamesPlayed for user $uid');

    } catch (e, stackTrace) {
      print('[FirestoreService] Error updating gamesPlayed in Firestore: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<GameData> fetchGameData(String idDataBase) async {
    try {
      return await GameData.fromFirestore(idDataBase, _firestore);
    } catch (e, stackTrace) {
      debugPrint("Error loading GameData: $e\n$stackTrace");
      rethrow;
    }
  }

  Future<UserData> fetchUserData(String userId) async {
    try {
      return await UserData.fromFirestore(userId, _firestore);
    } catch (e, stackTrace) {
      debugPrint("Error loading UserData: $e\n$stackTrace");
      rethrow;
    }
  }

  Future<String?> fetchUserType(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final data = userDoc.data();
      return data?['role'];
    } catch (e, stackTrace) {
      debugPrint("Error fetching user role: $e\n$stackTrace");
      return null;
    }
  }

  Future<void> registerUser({
    required String uid,
    required String name,
    required String username,
    required String selectedAccountType,
    required String email,
    required String birthDate,
  }) async {
    try {
      if (selectedAccountType == '') {
        throw Exception("No selected Account Type");
      }
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'username': username,
        'role': selectedAccountType,
        'email': email,
        'birthdate': birthDate,
        // Add 'gamesPlayed' field to Firestore with an empty list for new users
        'gamesPlayed': [],
      });
    } catch (e) {
      throw Exception("Unable to create user!");
    }
  }
}
