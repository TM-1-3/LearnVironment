import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/user_data.dart';

void main() {
  late UserData userData;
  late Map<String, String> cacheData;

  setUp(() {
    // Setup valid UserData instance
    userData = UserData(
      id: '123',
      username: 'testuser',
      email: 'test@example.com',
      name: 'Test User',
      role: 'admin',
      birthdate: DateTime(1990, 5, 15),
      gamesPlayed: ['game1', 'game2'],
    );

    // Get cache data from toCache method
    cacheData = userData.toCache();
  });

  group('UserData tests', () {
    test('Test toCache with valid data', () {
      expect(cacheData['id'], '123');
      expect(cacheData['username'], 'testuser');
      expect(cacheData['email'], 'test@example.com');
      expect(cacheData['name'], 'Test User');
      expect(cacheData['role'], 'admin');
      expect(cacheData['birthdate'], '1990-05-15T00:00:00.000');
      expect(cacheData['gamesPlayed'], 'game1,game2');
    });

    test('Test toCache with empty fields', () {
      final userDataWithEmptyFields = UserData(
        id: '',
        username: '',
        email: '',
        name: '',
        role: '',
        birthdate: DateTime(2000, 1, 1),  // Default date value
        gamesPlayed: [],
      );

      final cacheData = userDataWithEmptyFields.toCache();

      expect(cacheData['id'], '');
      expect(cacheData['username'], '');
      expect(cacheData['email'], '');
      expect(cacheData['name'], '');
      expect(cacheData['role'], '');
      expect(cacheData['birthdate'], '2000-01-01T00:00:00.000');
      expect(cacheData['gamesPlayed'], '');
    });

    test('Test fromCache with valid data', () {
      final cacheData = {
        'id': '123',
        'username': 'testuser',
        'email': 'test@example.com',
        'name': 'Test User',
        'role': 'admin',
        'birthdate': '1990-05-15T00:00:00.000',
        'gamesPlayed': 'game1,game2',
      };

      final userDataFromCache = UserData.fromCache(cacheData);

      expect(userDataFromCache.id, '123');
      expect(userDataFromCache.username, 'testuser');
      expect(userDataFromCache.email, 'test@example.com');
      expect(userDataFromCache.name, 'Test User');
      expect(userDataFromCache.role, 'admin');
      expect(userDataFromCache.birthdate, DateTime(1990, 5, 15));
      expect(userDataFromCache.gamesPlayed, ['game1', 'game2']);
    });

    test('Test fromCache with invalid data (empty values)', () {
      final cacheData = {
        'id': '',
        'username': '',
        'email': '',
        'name': '',
        'role': '',
        'birthdate': '',
        'gamesPlayed': '',
      };

      final userDataFromCache = UserData.fromCache(cacheData);

      expect(userDataFromCache.id, '');
      expect(userDataFromCache.username, '');
      expect(userDataFromCache.email, '');
      expect(userDataFromCache.name, '');
      expect(userDataFromCache.role, '');
      expect(userDataFromCache.birthdate, DateTime(2000));
      expect(userDataFromCache.gamesPlayed, ['']);
    });

    test('Test copyWith method', () {
      final updatedUserData = userData.copyWith(username: 'newusername', role: 'user');

      expect(updatedUserData.username, 'newusername');
      expect(updatedUserData.role, 'user');
      expect(updatedUserData.id, '123');  // Ensure unchanged fields remain the same
      expect(updatedUserData.email, 'test@example.com');
    });
  });
}
