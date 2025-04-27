import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learnvironment/data/subject_data.dart';

class SubjectCacheService {
  // Cache Subject Data
  Future<void> cacheSubjectData(SubjectData subjectData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'subject_${subjectData.subjectId}';
      final data = subjectData.toCache();

      print('[CACHE] Saving Subject ${subjectData.subjectId}');

      // Attempt to save the subject data to cache
      bool success = await prefs.setString(key, json.encode(data));

      if (success) {
        // Keep track of cached subject IDs
        List<String> cachedIds = prefs.getStringList('cached_subject_ids') ?? [];
        if (!cachedIds.contains(subjectData.subjectId)) {
          cachedIds.add(subjectData.subjectId);
          await prefs.setStringList('cached_subject_ids', cachedIds);
        }
        print('[CACHE] Subject ${subjectData.subjectId} cached successfully: $data');
      } else {
        print('[CACHE ERROR] Failed to save subject ${subjectData.subjectId} to cache.');
      }
    } catch (e) {
      print('[CACHE ERROR] Failed to cache subject ${subjectData.subjectId}: $e');
    }
  }

  // Retrieving Subject Data from Cache
  Future<SubjectData?> getCachedSubjectData(String subjectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'subject_$subjectId';
      final data = prefs.getString(key);

      if (data == null) {
        print('[CACHE] No cache found for subject $subjectId');
        return null;
      }

      // Decode the cached data
      try {
        final decoded = json.decode(data) as Map<String, dynamic>;

        // Convert the map to Map<String, String>
        final stringMap = Map<String, String>.from(decoded);

        print('[CACHE] Loaded subject $subjectId from cache.');
        return SubjectData.fromCache(stringMap);
      } catch (e) {
        print('[CACHE ERROR] Failed to decode cached subject $subjectId: $e');
        return null;
      }
    } catch (e) {
      print('[CACHE ERROR] Failed to retrieve subject $subjectId from cache: $e');
      return null;
    }
  }

  // Retrieving all cached Subject IDs
  Future<List<String>> getCachedSubjectIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('cached_subject_ids') ?? [];
    } catch (e) {
      print('[CACHE ERROR] Failed to retrieve cached subject IDs: $e');
      return [];
    }
  }
}