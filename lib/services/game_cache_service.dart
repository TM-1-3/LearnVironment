import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learnvironment/data/game_data.dart';

class GameCacheService {
  // Cache Game Data
  Future<void> cacheGameData(GameData gameData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'game_${gameData.documentName}';
      final data = gameData.toCache();

      print('[CACHE] Saving game ${gameData.documentName}');

      // Attempt to save the game data to cache
      bool success = await prefs.setString(key, json.encode(data));

      if (success) {
        // Keep track of cached game IDs
        List<String> cachedIds = prefs.getStringList('cached_game_ids') ?? [];
        if (!cachedIds.contains(gameData.documentName)) {
          cachedIds.add(gameData.documentName);
          await prefs.setStringList('cached_game_ids', cachedIds);
        }
        print('[CACHE] Game ${gameData.documentName} cached successfully: $data');
      } else {
        print('[CACHE ERROR] Failed to save game ${gameData.documentName} to cache.');
      }
    } catch (e) {
      print('[CACHE ERROR] Failed to cache game ${gameData.documentName}: $e');
    }
  }

  // Retrieving Game Data from Cache
  Future<GameData?> getCachedGameData(String gameId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'game_$gameId';
      final data = prefs.getString(key);

      if (data == null) {
        print('[CACHE] No cache found for game $gameId');
        return null;
      }

      // Decode the cached data
      try {
        final decoded = json.decode(data) as Map<String, dynamic>;

        // Convert the map to Map<String, String>
        final stringMap = Map<String, String>.from(decoded);

        print('[CACHE] Loaded game $gameId from cache.');
        return GameData.fromCache(stringMap);
      } catch (e) {
        print('[CACHE ERROR] Failed to decode cached game $gameId: $e');
        return null;
      }
    } catch (e) {
      print('[CACHE ERROR] Failed to retrieve game $gameId from cache: $e');
      return null;
    }
  }

  // Retrieving all cached Game IDs
  Future<List<String>> getCachedGameIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('cached_game_ids') ?? [];
    } catch (e) {
      print('[CACHE ERROR] Failed to retrieve cached game IDs: $e');
      return [];
    }
  }
}
