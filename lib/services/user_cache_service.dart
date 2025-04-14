import 'package:shared_preferences/shared_preferences.dart';
import 'package:learnvironment/data/user_data.dart';

class UserCacheService {
  Future<void> cacheUserData(UserData user) async {
    final prefs = await SharedPreferences.getInstance();
    final data = user.toCache();

    for (final entry in data.entries) {
      await prefs.setString(entry.key, entry.value);
    }
  }

  Future<UserData?> getCachedUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final keys = ['username', 'email', 'name', 'role', 'birthdate'];
    final Map<String, String> cachedData = {};

    for (final key in keys) {
      final value = prefs.getString(key);
      if (value == null) return null; // If any key is missing, return null
      cachedData[key] = value;
    }

    return UserData.fromCache(cachedData);
  }

  Future<void> clearUserCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('name');
    await prefs.remove('role');
    await prefs.remove('birthdate');
  }
}
