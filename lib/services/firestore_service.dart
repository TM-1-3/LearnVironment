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

  Future<GameData> fetchGameData(String gameId) async {
    try {
      // Fetch game data from Firestore
      DocumentSnapshot snapshot = await _firestore.collection('games').doc(gameId).get();

      if (!snapshot.exists) {
        throw Exception("Game not found in Firestore for ID: $gameId");
      }

      var data = snapshot.data() as Map<String, dynamic>;

      String template = data['template'] ?? '';
      Map<String, List<String>>? questionsAndOptions;
      Map<String, String>? correctAnswers;

      // If it's a quiz game, extract questions and answers
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
          throw Exception("Error parsing quiz fields for game $gameId: $e");
        }
      }

      // Return GameData object populated with Firestore data
      return GameData(
        gameLogo: data['logo'] ?? 'default_logo.png',
        gameName: data['name'] ?? 'Unnamed Game',
        gameDescription: data['description'] ?? 'No description available.',
        gameBibliography: data['bibliography'] ?? 'No bibliography available.',
        tags: List<String>.from(data['tags'] ?? []),
        gameTemplate: template,
        documentName: snapshot.id,
        questionsAndOptions: questionsAndOptions,
        correctAnswers: correctAnswers,
      );
    } catch (e, stackTrace) {
      debugPrint("Error loading GameData: $e\n$stackTrace");
      rethrow;
    }
  }

  Future<UserData> fetchUserData(String userId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(userId).get();

      if (!snapshot.exists) {
        throw Exception("User not found in Firestore for ID: $userId");
      }

      var data = snapshot.data() as Map<String, dynamic>;

      var birthdateField = data['birthdate'];
      DateTime birthdateValue;

      if (birthdateField is Timestamp) {
        birthdateValue = birthdateField.toDate();
      } else if (birthdateField is String) {
        birthdateValue = DateTime.tryParse(birthdateField) ?? DateTime(2000);
      } else {
        birthdateValue = DateTime(2000);
      }

      return UserData(
        id: userId,
        username: data['username'] ?? 'Unknown User',
        email: data['email'] ?? 'Unknown Email',
        name: data['name'] ?? 'Unknown Name',
        role: data['role'] ?? 'Unknown Role',
        birthdate: birthdateValue,
        gamesPlayed: List<String>.from(data['gamesPlayed'] ?? []),
      );
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
        'gamesPlayed': [],
      });
    } catch (e) {
      throw Exception("Unable to create user!");
    }
  }

  Future<void> deleteAccount(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      throw Exception("Error deleting account: $e");
    }
  }
}
