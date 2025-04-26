import 'package:flutter/widgets.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/services/firestore_service.dart';
import 'package:learnvironment/services/game_cache_service.dart';
import 'package:learnvironment/services/user_cache_service.dart';
import 'package:provider/provider.dart';

class DataService {
  late final FirestoreService _firestoreService;
  late final UserCacheService _userCacheService;
  late final GameCacheService _gameCacheService;

  DataService(BuildContext context) {
    _firestoreService = Provider.of<FirestoreService>(context, listen: false);
    _userCacheService = Provider.of<UserCacheService>(context, listen: false);
    _gameCacheService = Provider.of<GameCacheService>(context, listen: false);
  }

  Future<List<Map<String, dynamic>>> getPlayedGames({required String userId}) async {
    try {
      final cachedGames = await _userCacheService.getCachedGamesPlayed();

      if (cachedGames.isNotEmpty) {
        print('[DataService] Loaded gamesPlayed from cache: $cachedGames');

        final games = await Future.wait(cachedGames.map((id) async {
          final game = await getGameData(gameId: id);
          if (game != null) {
            return {
              'imagePath': game.gameLogo,
              'gameTitle': game.gameName,
              'tags': game.tags,
              'gameId': game.documentName,
            };
          }
          return null;
        }));
        return games.whereType<Map<String, dynamic>>().toList();
      }

      print('[DataService] Cache empty — falling back to Firestore');
      return await _firestoreService.getPlayedGames(uid: userId);
    } catch (e, stack) {
      print('[DataService] Error in getPlayedGames: $e\n$stack');
      return [];
    }
  }

  // Function to update the 'gamesPlayed' array in both Firestore and the cache
  Future<void> updateUserGamesPlayed({required String userId, required String gameId}) async {
    try {
      print('[DataService] Updating gamesPlayed for userId: $userId, gameId: $gameId');

      // Update Firestore
      await _firestoreService.updateUserGamesPlayed(uid: userId, gameId: gameId);
      print('[DataService] Firestore updated successfully');

      // Fetch the user data from cache
      final cachedUser = await _userCacheService.getCachedUserData();
      if (cachedUser != null && cachedUser.id == userId) {
        _userCacheService.updateCachedGamesPlayed(gameId);
        print('[DataService] Cached user data updated with new gamesPlayed');
      } else {
        print('[DataService] User data not found in cache');
      }

    } catch (e) {
      print('[DataService] Error updating user\'s gamesPlayed: $e');
      throw Exception("Error updating user's gamesPlayed");
    }
  }

  Future<UserData?> getUserData({required String userId}) async {
    try {
      final cachedUser = await _userCacheService.getCachedUserData();

      if (cachedUser != null && cachedUser.id == userId) {
        print('[DataService] Loaded user from cache');
        return cachedUser;
      }

      final freshUser = await _firestoreService.fetchUserData(userId: userId);
      await _userCacheService.cacheUserData(freshUser);
      print('[DataService] Loaded user from Firestore and cached it');

      return freshUser;
    } catch (e) {
      print('[DataService] Error getting user data: $e');
      return null;
    }
  }


  Future<GameData?> getGameData({required String gameId}) async {
    try {
      final cachedGame = await _gameCacheService.getCachedGameData(gameId);
      if (cachedGame != null) {
        print('[DataService] Loaded game from cache');
        return cachedGame;
      }

      final freshGame = await _firestoreService.fetchGameData(gameId: gameId);
      await _gameCacheService.cacheGameData(freshGame);
      print('[DataService] Loaded game from Firestore and cached it');
      return freshGame;
    } catch (e) {
      print('[DataService] Error getting game data: $e');
      return null;
    }
  }

  // Function to fetch all games, handling cache and Firestore
  Future<List<Map<String, dynamic>>> getAllGames() async {
    try {
      // First, try to load cached game IDs
      final cachedIds = await _gameCacheService.getCachedGameIds();
      List<Map<String, dynamic>> loadedGames = [];

      // Try to load each cached game
      for (final id in cachedIds) {
        final cachedGame = await _gameCacheService.getCachedGameData(id);
        if (cachedGame != null) {
          loadedGames.add({
            'imagePath': cachedGame.gameLogo,
            'gameTitle': cachedGame.gameName,
            'tags': cachedGame.tags,
            'gameId': cachedGame.documentName,
          });
        }
      }

      // If no cached games, return an empty list
      if (loadedGames.isNotEmpty) {
        print('[DataService] Loaded games from cache');
        return loadedGames;
      }

      // If no cached games, fetch games from Firestore
      final fetchedGames = await _firestoreService.getAllGames();
      for (final game in fetchedGames) {
        final gameId = game['gameId'];
        final gameData = await _firestoreService.fetchGameData(gameId: gameId);
        await _gameCacheService.cacheGameData(gameData);
      }

      print('[DataService] Loaded games from Firestore and cached them');
      return fetchedGames;
    } catch (e) {
      print('[DataService] Error fetching games: $e');
      return [];
    }
  }

  Future<void> deleteAccount({required String uid}) async {
    try {
      await _firestoreService.deleteAccount(uid: uid);
      await _userCacheService.clearUserCache();
      print("[DataService] Account deleted");
    } catch(e) {
      print("[DataService] Error deleting account");
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String username,
    required String email,
    required String birthDate,
    required String role,
    required String img
  }) async {
    try {
      await _firestoreService.setUserInfo(uid: uid, name: name, email: email, username: username, birthDate: birthDate, selectedAccountType: role, img: img);
      final List<String> gamesPlayed = await _userCacheService.getCachedGamesPlayed();
      final List<String> classes = await _userCacheService.getCachedClasses();
      await _userCacheService.clearUserCache();
      await _userCacheService.cacheUserData(UserData(id: uid, username: username, email: email, name: name, role: role, birthdate: DateTime.parse(birthDate), gamesPlayed: gamesPlayed, classes: classes, img: img));
    } catch (e) {
      print("Error updating profile");
    }
  }

  Future<void> createAssignment({
    required String title,
    required DateTime dueDate,
    required String turma,
    required String gameId,
  }) async {
    try {
      await _firestoreService.createAssignment(title: title, dueDate: dueDate.toString(), turma: turma, gameId: gameId);
      //await _userCacheService.addAssignment(title: title, dueDate: DateTime.parse(dueDate), turma: turma, gameid: game_id);
    } catch (e) {
      print("Error creating Assigment");
    }
  }
}