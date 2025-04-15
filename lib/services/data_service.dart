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

  Future<List<Map<String, dynamic>>> getPlayedGames(String userId) async {
    try {
      // Try from cache first
      final cachedGames = await _userCacheService.getCachedGamesPlayed();

      if (cachedGames.isNotEmpty) {
        print('[DataService] Loaded gamesPlayed from cache: $cachedGames');

        final games = await Future.wait(cachedGames.map((id) async {
          final game = await getGameData(id); // Uses cache or Firestore internally
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

      // Fallback to Firestore if cache is empty
      print('[DataService] Cache empty — falling back to Firestore');

      return await _firestoreService.getPlayedGames(userId);
    } catch (e, stack) {
      print('[DataService] Error in getPlayedGames: $e\n$stack');
      return [];
    }
  }

  // Function to update the 'gamesPlayed' array in both Firestore and the cache
  Future<void> updateUserGamesPlayed(String userId, String gameId) async {
    try {
      print('[DataService] Updating gamesPlayed for userId: $userId, gameId: $gameId');

      // Update Firestore
      await _firestoreService.updateUserGamesPlayed(userId, gameId);
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

  Future<UserData?> getUserData(String userId) async {
    try {
      // Try loading user data from cache
      final cachedUser = await _userCacheService.getCachedUserData();

      if (cachedUser != null && cachedUser.id == userId) {
        print('[DataService] Loaded user from cache');
        return cachedUser;
      }

      final freshUser = await _firestoreService.fetchUserData(userId);
      await _userCacheService.cacheUserData(freshUser);
      print('[DataService] Loaded user from Firestore and cached it');

      return freshUser;
    } catch (e) {
      print('[DataService] Error getting user data: $e');
      return null;
    }
  }


  Future<GameData?> getGameData(String gameId) async {
    try {
      final cachedGame = await _gameCacheService.getCachedGameData(gameId);
      if (cachedGame != null) {
        print('[DataService] Loaded game from cache');
        return cachedGame;
      }

      final freshGame = await _firestoreService.fetchGameData(gameId);
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
        final gameData = await _firestoreService.fetchGameData(gameId);
        await _gameCacheService.cacheGameData(gameData);
      }

      print('[DataService] Loaded games from Firestore and cached them');
      return fetchedGames;
    } catch (e) {
      print('[DataService] Error fetching games: $e');
      return [];
    }
  }

  Future<void> deleteAccount(String uid) async {
    try {
      await _firestoreService.deleteAccount(uid);
      await _userCacheService.clearUserCache();
      print("[DataService] Account deleted");
    } catch(e) {
      print("[DataService] Error deleting account");
      rethrow;
    }
  }
}
