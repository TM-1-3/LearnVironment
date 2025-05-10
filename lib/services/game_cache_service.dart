import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learnvironment/data/game_data.dart';

class GameCacheService {
  // Cache Game Data
  Future<void> cacheGameData(GameData gameData) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'game_${gameData.documentName}';

    final data = {
      'game': gameData.toCache(),
      'expiresAt': DateTime.now().add(Duration(days: 5)).millisecondsSinceEpoch
    };

    print('[CACHE] Saving game ${gameData.documentName}');

    bool success = await prefs.setString(key, json.encode(data));

    if (success) {
      List<String> cachedIds = prefs.getStringList('cached_game_ids') ?? [];
      if (!cachedIds.contains(gameData.documentName)) {
        cachedIds.add(gameData.documentName);
        await prefs.setStringList('cached_game_ids', cachedIds);
      }
      print('[CACHE] Game ${gameData.documentName} cached with expiration.');
    } else {
      print('[CACHE ERROR] Failed to cache game ${gameData.documentName}.');
    }
  }

  // Retrieving Game Data from Cache
  Future<GameData?> getCachedGameData(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'game_$gameId';
    final rawData = prefs.getString(key);

    if (rawData == null) {
      print('[CACHE] No cache found for game $gameId');
      return null;
    }

    try {
      final decoded = json.decode(rawData);
      final expiresAt = decoded['expiresAt'] as int?;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (expiresAt != null && now > expiresAt) {
        print('[CACHE] Game $gameId cache expired. Deleting...');
        await prefs.remove(key);

        // Also remove from cached_game_ids list
        List<String> cachedIds = prefs.getStringList('cached_game_ids') ?? [];
        cachedIds.remove(gameId);
        await prefs.setStringList('cached_game_ids', cachedIds);

        return null;
      }

      final gameDataMap = Map<String, String>.from(decoded['game']);
      return GameData.fromCache(gameDataMap);
    } catch (e) {
      print('[CACHE ERROR] Failed to decode or process cached game $gameId: $e');
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

  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedIds = prefs.getStringList('cached_game_ids') ?? [];

      // Remove each game's cache
      for (String id in cachedIds) {
        await prefs.remove('game_$id');
      }

      // Remove the cached_game_ids list
      await prefs.remove('cached_game_ids');

      print('[CACHE] All cached games cleared.');
    } catch (e) {
      print('[CACHE ERROR] Failed to clear GAMECACHE: $e');
    }
  }
}
