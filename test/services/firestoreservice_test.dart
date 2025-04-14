import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:learnvironment/services/firestore_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreService firestoreService;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    firestoreService = FirestoreService(firestore: firestore);
  });

  group('getAllGames Tests', () {
    test('getAllGames should return empty list if no games exist', () async {
      final games = await firestoreService.getAllGames();
      expect(games, isEmpty);
    });

    test('getAllGames should return list of games', () async {
      await firestore.collection('games').add({
        'logo': 'assets/logo.png',
        'name': 'Test Game',
        'tags': ['educational', 'math']
      });

      final games = await firestoreService.getAllGames();

      expect(games.length, 1);
      expect(games[0]['imagePath'], 'assets/logo.png');
      expect(games[0]['gameTitle'], 'Test Game');
      expect(games[0]['tags'], contains('math'));
    });

    test('getAllGames should handle missing fields safely', () async {
      await firestore.collection('games').add({}); // Missing all expected fields

      final games = await firestoreService.getAllGames();

      expect(games.length, 1);
      expect(games[0]['imagePath'], 'assets/placeholder.png');
      expect(games[0]['gameTitle'], 'Default Game Title');
      expect(games[0]['tags'], isEmpty);
    });
  });

  group('fetchGameData Tests', () {
    test('fetchGameData should throw exception if error occurs', () async {
      try {
        await firestoreService.fetchGameData('non_existing_game');
        fail('Expected an exception to be thrown');
      } catch (e) {
        expect(e.toString(), contains('Game not found!'));
      }
    });

    test('fetchGameData should return GameData if exists', () async {
      final docRef = await firestore.collection('games').add({
        'logo': 'game_logo.png',
        'name': 'Game 2',
        'description': 'Game 2 Description',
        'bibliography': 'Game 2 Bibliography',
        'tags': ['strategy', 'simulation'],
        'template': 'drag',
      });

      final gameData = await firestoreService.fetchGameData(docRef.id);

      expect(gameData.gameLogo, 'game_logo.png');
      expect(gameData.gameName, 'Game 2');
      expect(gameData.gameDescription, 'Game 2 Description');
      expect(gameData.gameBibliography, 'Game 2 Bibliography');
      expect(gameData.tags, ['strategy', 'simulation']);
      expect(gameData.gameTemplate, 'drag');
      expect(gameData.documentName, docRef.id);
    });
  });

  group('fetchUserData Tests', () {
    test('fetchUserData should throw exception if error occurs', () async {
      try {
        await firestoreService.fetchUserData('non_existing_user');
        fail('Expected an exception to be thrown');
      } catch (e) {
        expect(e.toString(), contains('User not found!'));
      }
    });

    test('fetchUserData should return UserData if exists', () async {
      final docRef = await firestore.collection('users').add({
        'username': 'Lebi',
        'email': 'up202307719@g.uporto.pt',
        'name': 'L',
        'role': 'developer',
        'birthdate': Timestamp.fromDate(DateTime(2000, 1, 1)),
      });

      final userDataFetched = await firestoreService.fetchUserData(docRef.id);

      expect(userDataFetched.username, 'Lebi');
      expect(userDataFetched.email, 'up202307719@g.uporto.pt');
      expect(userDataFetched.name, 'L');
      expect(userDataFetched.role, 'developer');
      expect(userDataFetched.birthdate, DateTime(2000, 1, 1));
    });
  });

  group('fetchUserType Tests', () {
    test('fetchUserType returns developer', () async {
      final uid = 'testDeveloper';
      await firestore.collection('users').doc(uid).set({
        'role': 'developer',
      });

      final userRole = await firestoreService.fetchUserType(uid);

      expect(userRole, 'developer');
    });

    test('fetchUserType returns student', () async {
      final uid = 'testStudent';
      await firestore.collection('users').doc(uid).set({
        'role': 'student',
      });

      final userRole = await firestoreService.fetchUserType(uid);

      expect(userRole, 'student');
    });

    test('fetchUserType returns null if user not found', () async {
      final uid = 'non_existing_uid';

      final userRole = await firestoreService.fetchUserType(uid);

      expect(userRole, null);
    });

    test('fetchUserType returns null if role field is null', () async {
      final uid = 'null_role_user';
      await firestore.collection('users').doc(uid).set({
        'role': null,
      });

      final userRole = await firestoreService.fetchUserType(uid);

      expect(userRole, null);
    });

    test('fetchUserType handles unexpected errors', () async {
      final uid = 'invalid_user';
      await firestore.collection('users').doc(uid).set({});
      final userRole = await firestoreService.fetchUserType(uid);

      expect(userRole, null);
    });
  });

  group('getPlayedGames Tests', () {
    test('getPlayedGames should return empty list if no games are played', () async {
      final uid = 'userWithNoGames';
      // Set gamesPlayed as an empty list
      await firestore.collection('users').doc(uid).set({
        'gamesPlayed': [],
      });

      final games = await firestoreService.getPlayedGames(uid);

      expect(games, isEmpty);
    });

    test('getPlayedGames should return list of games if user has played games', () async {
      final uid = 'userWithGames';

      // Add a game to the 'games' collection first
      await firestore.collection('games').doc('game1').set({
        'logo': 'assets/logo.png',
        'name': 'Test Game',
        'tags': ['educational', 'math'],
      });

      // Now set the 'gamesPlayed' field with game IDs (array of strings)
      await firestore.collection('users').doc(uid).set({
        'gamesPlayed': ['game1'], // List of game IDs as strings
      });

      final games = await firestoreService.getPlayedGames(uid);

      expect(games.length, 1);
      expect(games[0]['imagePath'], 'assets/logo.png');
      expect(games[0]['gameTitle'], 'Test Game');
      expect(games[0]['tags'], contains('math'));
    });

    test('getPlayedGames should return empty list if gamesPlayed field is missing', () async {
      final uid = 'userWithoutGamesField';
      // User document without 'gamesPlayed' field
      await firestore.collection('users').doc(uid).set({});
      final games = await firestoreService.getPlayedGames(uid);

      expect(games, isEmpty);
    });

    test('getPlayedGames should handle invalid data structure in gamesPlayed field', () async {
      final uid = 'userWithInvalidGamesData';

      // Add a game to the 'games' collection first
      await firestore.collection('games').doc('game1').set({
        'logo': 'assets/logo.png',
        'name': 'Test Game',
        'tags': ['educational', 'math'],
      });

      // Now set the 'gamesPlayed' field with invalid data structure (e.g., non-string values)
      await firestore.collection('users').doc(uid).set({
        'gamesPlayed': [12345], // Invalid game ID (not a string)
      });

      final games = await firestoreService.getPlayedGames(uid);

      expect(games, isEmpty);
    });

    test('getPlayedGames should return empty list if game ID does not exist in the games collection', () async {
      final uid = 'userWithNonExistingGameId';

      // Set the 'gamesPlayed' field with a non-existing game ID
      await firestore.collection('users').doc(uid).set({
        'gamesPlayed': ['non_existing_game_id'],
      });

      final games = await firestoreService.getPlayedGames(uid);

      expect(games, isEmpty); // No game data should be returned
    });
  });
}
