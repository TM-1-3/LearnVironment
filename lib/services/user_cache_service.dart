import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learnvironment/data/user_data.dart';

class UserCacheService {
  // Cache user data with error handling and debug prints
  Future<void> cacheUserData(UserData user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = user.toCache();

      print('[CACHE] Saving user data: $data');

      for (final entry in data.entries) {
        final success = await prefs.setString(entry.key, entry.value);
        if (!success) {
          print('[CACHE ERROR] Failed to cache data for key: ${entry.key}');
          throw Exception('Failed to cache data for key: ${entry.key}');
        }
      }

      print('[CACHE] User data saved to cache successfully.');
    } catch (e) {
      print('[CACHE ERROR] Error caching user data: $e');
      rethrow;  // Re-throw the error to handle it higher up the call stack
    }
  }

  // Retrieve cached user data with error handling and debug prints
  Future<UserData?> getCachedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = ['id', 'username', 'email', 'name', 'role', 'birthdate', 'gamesPlayed'];
      final Map<String, String> cachedData = {};

      print('[CACHE] Loading user data from cache...');

      // Log and retrieve each key
      for (final key in keys) {
        final value = prefs.getString(key);
        if (value == null) {
          print('[CACHE] Cache miss for key: $key');
          return null; // Fail early if anything is missing
        }

        cachedData[key] = value;
      }

      print('[CACHE] Loaded user data from cache: $cachedData');

      // Return reconstructed UserData
      return UserData(
        id: cachedData['id']!,
        username: cachedData['username']!,
        email: cachedData['email']!,
        name: cachedData['name']!,
        role: cachedData['role']!,
        birthdate: DateTime.tryParse(cachedData['birthdate']!) ?? DateTime(2000),
        gamesPlayed: cachedData['gamesPlayed']!.isEmpty
            ? []
            : cachedData['gamesPlayed']!.split(','),
      );
    } catch (e) {
      print('[CACHE ERROR] Error retrieving cached user data: $e');
      return null;
    }
  }


  // Clear user data from cache with error handling and debug prints
  Future<void> clearUserCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = ['id', 'username', 'email', 'name', 'role', 'birthdate'];

      print('[CACHE] Clearing user cache...');

      // Attempt to remove each key
      for (final key in keys) {
        final success = await prefs.remove(key);
        if (!success) {
          print('[CACHE ERROR] Failed to remove key: $key');
        } else {
          print('[CACHE] Successfully removed key: $key');
        }
      }

      print('[CACHE] User cache cleared successfully.');
    } catch (e) {
      print('[CACHE ERROR] Error clearing user cache: $e');
    }
  }

  Future<void> updateCachedGamesPlayed(String gameId) async {
    try {
      // Fetch cached user data
      UserData? cachedUser = await getCachedUserData();

      if (cachedUser != null) {
        // Update the gamesPlayed list in the cached data
        List<String> gamesPlayed = List.from(cachedUser.gamesPlayed);

        // Remove the gameId if it already exists, and add it at the start
        gamesPlayed.remove(gameId);
        gamesPlayed.insert(0, gameId);

        // Create a new UserData with updated gamesPlayed
        UserData updatedUser = cachedUser.copyWith(gamesPlayed: gamesPlayed);

        // Cache the updated user data
        await cacheUserData(updatedUser);
        print('[UserCacheService] Updated cached gamesPlayed');
      }
    } catch (e) {
      print('[UserCacheService] Error updating cached gamesPlayed: $e');
      rethrow;
    }
  }

  Future<List<String>> getCachedGamesPlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawGamesPlayed = prefs.getString('gamesPlayed');

      if (rawGamesPlayed == null || rawGamesPlayed.isEmpty) {
        print('[CACHE] No cached gamesPlayed found.');
        return [];
      }

      final games = rawGamesPlayed.split(',').where((id) => id.isNotEmpty).toList();
      print('[CACHE] Loaded gamesPlayed from cache: $games');
      return games;
    } catch (e) {
      print('[CACHE ERROR] Failed to get cached gamesPlayed: $e');
      return [];
    }
  }
}
