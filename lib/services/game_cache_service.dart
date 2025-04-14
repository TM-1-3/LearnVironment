import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learnvironment/data/game_data.dart';

class GameCacheService {
  Future<void> cacheGameData(GameData gameData) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'game_${gameData.documentName}';
    final data = gameData.toCache();

    print('[CACHE] Saving game ${gameData.documentName}');

    await prefs.setString(key, json.encode(data));

    // Keep track of cached game IDs
    List<String> cachedIds = prefs.getStringList('cached_game_ids') ?? [];
    if (!cachedIds.contains(gameData.documentName)) {
      cachedIds.add(gameData.documentName);
      await prefs.setStringList('cached_game_ids', cachedIds);
    }
  }

  // Retrieving Game Data from Cache
  Future<GameData?> getCachedGameData(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'game_$gameId';
    final data = prefs.getString(key);

    if (data == null) {
      print('[CACHE] No cache found for game $gameId');
      return null;
    }

    try {
      final decoded = json.decode(data) as Map<String, dynamic>;

      // Now we explicitly convert the map to Map<String, String>
      final stringMap = Map<String, String>.from(decoded);

      print('[CACHE] Loaded game $gameId');
      return GameData.fromCache(stringMap);
    } catch (e) {
      print('[CACHE ERROR] Failed to decode game $gameId: $e');
      return null;
    }
  }

  // Retrieving all cached Game IDs
  Future<List<String>> getCachedGameIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('cached_game_ids') ?? [];
  }
}
