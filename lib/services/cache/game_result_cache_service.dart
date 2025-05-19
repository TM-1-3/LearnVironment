import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/game_result_data.dart';

class GameResultCacheService {
  // Cache a single GameResultData by appending it to the existing cached list
  Future<void> cacheGameResult(GameResultData result) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'results_${result.studentId}';

    // Load existing cached results
    final rawData = prefs.getString(key);
    List<Map<String, dynamic>> resultsMap = [];

    if (rawData != null) {
      try {
        final decoded = json.decode(rawData);
        resultsMap = List<Map<String, dynamic>>.from(decoded['results']);
      } catch (e) {
        print('[CACHE ERROR] Failed to decode existing results: $e');
        // Continue with empty list
      }
    }

    // Append new result
    resultsMap.add(result.toCache());

    // Wrap with expiration
    final data = {
      'results': resultsMap,
      'expiresAt': DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch,
    };

    final success = await prefs.setString(key, json.encode(data));

    if (success) {
      print('[CACHE] Cached 1 new result for student ${result.studentId} (total: ${resultsMap.length})');
    } else {
      print('[CACHE ERROR] Failed to cache result for student ${result.studentId}');
    }
  }

  // Retrieve cached results
  Future<List<GameResultData>?> getCachedGameResults(String studentId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'results_$studentId';
    final rawData = prefs.getString(key);

    if (rawData == null) {
      print('[CACHE] No cached results for student $studentId');
      return null;
    }

    try {
      final decoded = json.decode(rawData);
      final expiresAt = decoded['expiresAt'] as int?;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (expiresAt != null && now > expiresAt) {
        print('[CACHE] Cached results for student $studentId expired, removing...');
        await prefs.remove(key);
        return null;
      }

      final resultsList = List<Map<String, dynamic>>.from(decoded['results']);
      final gameResults = resultsList.map((resultMap) {
        return GameResultData(
          subjectId: resultMap['subjectId'],
          studentId: resultMap['studentId'],
          gameId: resultMap['gameId'],
          correctCount: resultMap['correctCount'],
          wrongCount: resultMap['wrongCount'],
          timestamp: DateTime.parse(resultMap['timestamp']),
        );
      }).toList();

      return gameResults;
    } catch (e) {
      print('[CACHE ERROR] Failed to decode cached results for student $studentId: $e');
      return null;
    }
  }

  Future<void> clearCachedResults(String studentId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'results_$studentId';
    await prefs.remove(key);
    print('[CACHE] Cleared cached results for student $studentId');
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('results_')).toList();

    for (final key in keys) {
      await prefs.remove(key);
    }
    print('[CACHE] Cleared all cached game results.');
  }
}
