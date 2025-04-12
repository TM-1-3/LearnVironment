import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:learnvironment/main_pages/data/game_data.dart';

void main() {
  late FirebaseFirestore firestore;

  setUp(() {
    // Initialize fake Firestore before each test
    firestore = FakeFirebaseFirestore();
  });

  test('GameData.fromFirestore should return a valid GameData object', () async {
    // Prepare mock data in Firestore
    await firestore.collection('games').doc('game1').set({
      'logo': 'game_logo.png',
      'name': 'Game Name',
      'description': 'Game Description',
      'bibliography': 'Game Bibliography',
      'tags': ['action', 'adventure'],
    });

    // Fetch the GameData from Firestore
    GameData gameData = await GameData.fromFirestore('game1', firestore);

    // Verify that the fetched data matches the expected values
    expect(gameData.gameLogo, 'game_logo.png');
    expect(gameData.gameName, 'Game Name');
    expect(gameData.gameDescription, 'Game Description');
    expect(gameData.gameBibliography, 'Game Bibliography');
    expect(gameData.tags, ['action', 'adventure']);
  });

  test('GameData.fromFirestore should throw exception if game not found', () async {
    try {
      // Attempt to fetch a game that does not exist
      await GameData.fromFirestore('non_existing_game', firestore);
      fail('Expected an exception to be thrown');
    } catch (e) {
      // Verify that the exception is thrown
      expect(e.toString(), contains('Jogo não encontrado!'));
    }
  });

  test('fetchGameData should return valid GameData', () async {
    // Set up the mock Firestore data
    await firestore.collection('games').doc('game2').set({
      'logo': 'game_logo.png',
      'name': 'Game 2',
      'description': 'Game 2 Description',
      'bibliography': 'Game 2 Bibliography',
      'tags': ['strategy', 'simulation'],
    });

    // Call the fetchGameData function
    GameData gameData = await fetchGameData('game2', firestore: firestore);

    // Verify that the fetched data is correct
    expect(gameData.gameLogo, 'game_logo.png');
    expect(gameData.gameName, 'Game 2');
    expect(gameData.gameDescription, 'Game 2 Description');
    expect(gameData.gameBibliography, 'Game 2 Bibliography');
    expect(gameData.tags, ['strategy', 'simulation']);
  });

  test('fetchGameData should throw exception if error occurs', () async {
    // Mock an error by calling a non-existent document
    try {
      await fetchGameData('non_existing_game');
      fail('Expected an exception to be thrown');
    } catch (e) {
      // Ensure that the exception message is what we expect
      expect(e.toString(), contains('Erro ao carregar dados do jogo'));
    }
  });
}