import 'dart:convert';
import 'package:learnvironment/data/assignment_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssignmentCacheService {
  // Cache Assignment Data
  Future<void> cacheAssignmentData(AssignmentData assignmentData) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'assignment_${assignmentData.title}';

    final data = {
      'assignment': assignmentData.toCache(),
      'expiresAt': DateTime.now().add(Duration(days: 5)).millisecondsSinceEpoch
    };

    print('[CACHE] Saving assignment ${assignmentData.title}');

    bool success = await prefs.setString(key, json.encode(data));

    if (success) {
      List<String> cachedIds = prefs.getStringList('cached_assignment_ids') ?? [];
      if (!cachedIds.contains(assignmentData.title)) {
        cachedIds.add(assignmentData.title);
        await prefs.setStringList('cached_assignment_ids', cachedIds);
      }
      print('[CACHE] Assignment ${assignmentData.title} cached with expiration.');
    } else {
      print('[CACHE ERROR] Failed to cache assignment ${assignmentData.title}.');
    }
  }

  // Retrieving Assignment Data from Cache
  Future<AssignmentData?> getCachedAssignmentData(String assignmentId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'assignment_$assignmentId';
    final rawData = prefs.getString(key);

    if (rawData == null) {
      print('[CACHE] No cache found for assignment $assignmentId');
      return null;
    }

    try {
      final decoded = json.decode(rawData);
      final expiresAt = decoded['expiresAt'] as int?;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (expiresAt != null && now > expiresAt) {
        print('[CACHE] Assignment $assignmentId cache expired. Deleting...');
        await prefs.remove(key);

        // Also remove from cached_game_ids list
        List<String> cachedIds = prefs.getStringList('cached_assignment_ids') ?? [];
        cachedIds.remove(assignmentId);
        await prefs.setStringList('cached_assignment_ids', cachedIds);

        return null;
      }

      final assignmentDataMap = Map<String, String>.from(decoded['assignment']);
      return AssignmentData.fromCache(assignmentDataMap);
    } catch (e) {
      print('[CACHE ERROR] Failed to decode or process cached game $assignmentId: $e');
      return null;
    }
  }

  // Retrieving all cached Assignment IDs
  Future<List<String>> getCachedAssignmentIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('cached_assignment_ids') ?? [];
    } catch (e) {
      print('[CACHE ERROR] Failed to retrieve cached assignment IDs: $e');
      return [];
    }
  }

  Future<void> deleteAssignment({required String assignmentId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'assignment_$assignmentId';

      // Remove the cached assignment data
      bool success = await prefs.remove(key);

      if (success) {
        print('[CACHE] Assignment $assignmentId removed from cache.');

        // Also update the cached_assignment_ids list
        List<String> cachedIds = prefs.getStringList('cached_assignment_ids') ?? [];
        cachedIds.remove(assignmentId);
        await prefs.setStringList('cached_assignment_ids', cachedIds);

        print('[CACHE] Updated cached_assignment_ids list.');
      } else {
        print('[CACHE ERROR] Failed to remove assignment $assignmentId from cache.');
      }
    } catch (e) {
      print('[CACHE ERROR] Exception while deleting assignment $assignmentId: $e');
    }
  }

  Future<void> clearAssignmentCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedIds = prefs.getStringList('cached_assignment_ids') ?? [];

      print('[CACHE] Clearing assignment cache...');

      // Remove each cached assignment
      for (final assignmentId in cachedIds) {
        final key = 'assignment_$assignmentId';
        final success = await prefs.remove(key);
        if (!success) {
          print('[CACHE ERROR] Failed to remove assignment: $assignmentId');
        } else {
          print('[CACHE] Successfully removed assignment: $assignmentId');
        }
      }

      // Clear the cached assignment IDs list
      await prefs.remove('cached_assignment_ids');

      print('[CACHE] Assignment cache cleared successfully.');
    } catch (e) {
      print('[CACHE ERROR] Error clearing assignment cache: $e');
    }
  }

}
