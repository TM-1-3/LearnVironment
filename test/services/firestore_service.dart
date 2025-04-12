import 'dart:math';

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

  test('getAllGames should throw exception when missing data', () async {
    await firestore.collection('games').add({});
    try {
      await firestoreService.getAllGames();
      fail("Expected an exception!");
    } catch(e) {
      expect(e.toString(), contains('Error loading data from Firestore'));
    }
  });

  test('fetchGameData should throw exception if error occurs', () async {
    try {
      await firestoreService.fetchGameData('non_existing_game');
      fail('Expected an exception to be thrown');
    } catch (e) {
      expect(e.toString(), contains('Error loading data from Firestore'));
    }
  });

  test('fetchGameData should return GameData if exists', () async {
    final docRef = await firestore.collection('games').add({
      'logo': 'game_logo.png',
      'name': 'Game 2',
      'description': 'Game 2 Description',
      'bibliography': 'Game 2 Bibliography',
      'tags': ['strategy', 'simulation'],
      'template' : 'drag'});

    final gameData = await firestoreService.fetchGameData(docRef.id);

    expect(gameData.gameLogo, 'game_logo.png');
    expect(gameData.gameName, 'Game 2');
    expect(gameData.gameDescription, 'Game 2 Description');
    expect(gameData.gameBibliography, 'Game 2 Bibliography');
    expect(gameData.tags, ['strategy', 'simulation']);
    expect(gameData.gameTemplate, 'drag');
    expect(gameData.documentName, 'game2');
  });

  test('fetchUserData should throw exception if error occurs', () async {
    try {
      await firestoreService.fetchUserData('non_existing_user');
      fail('Expected an exception to be thrown');
    } catch (e) {
      expect(e.toString(), contains('Error loading data from Firestore'));
    }
  });

  test('fetchUserData should return UserData if exists', () async {
    final docRef = await firestore.collection('users').add({
      'username': 'Lebi',
      'email': 'up202307719@g.uporto.pt',
      'name': 'L',
      'role': 'developer',
      'birthdate': Timestamp.fromDate(DateTime(2000, 1, 1))});

    final userDataFetched = await firestoreService.fetchUserData(docRef.id);

    expect(userDataFetched.username, 'Lebi');
    expect(userDataFetched.email, 'up202307719@g.uporto.pt');
    expect(userDataFetched.name, 'L');
    expect(userDataFetched.role, 'developer');
    expect(userDataFetched.birthdate, DateTime(2000, 1, 1));
  });
}