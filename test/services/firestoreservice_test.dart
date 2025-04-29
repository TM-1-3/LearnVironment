import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:learnvironment/services/firestore_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreService firestoreService;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    final Map<String, List<String>> questionsAndOptions = {
      "What is recycling?": [
        "Reusing materials",
        "Throwing trash",
        "Saving money",
        "Buying new things"
      ],
      "Why should we save water?": [
        "It helps the earth",
        "Water is unlimited",
        "For fun",
        "It doesn't matter"
      ],
      "What do trees do for us?": [
        "Give oxygen",
        "Make noise",
        "Take water",
        "Eat food"
      ],
      "How can we reduce waste?": [
        "Recycle",
        "Burn trash",
        "Throw in rivers",
        "Ignore it"
      ],
      "What animals live in the ocean?": ["Sharks", "Lions", "Elephants", "Cows"],
      "What happens if we pollute rivers?": [
        "Fish die",
        "More water appears",
        "Trees grow faster",
        "It smells better"
      ],
      "Why is the sun important?": [
        "Gives us light",
        "Cools the earth",
        "Makes rain",
        "Creates snow"
      ],
      "How can we help the planet?": [
        "Pick up trash",
        "Cut all trees",
        "Pollute more",
        "Use plastic"
      ],
      "What is composting?": [
        "Turning food waste into soil",
        "Burning paper",
        "Throwing food in the trash",
        "Using plastic"
      ],
      "Why should we turn off the lights?": [
        "Save energy",
        "Break the bulb",
        "Change the color",
        "Make it brighter"
      ]
    };

    final Map<String, String> correctAnswers = {
      "What is recycling?": "Reusing materials",
      "Why should we save water?": "It helps the earth",
      "What do trees do for us?": "Give oxygen",
      "How can we reduce waste?": "Recycle",
      "What animals live in the ocean?": "Sharks",
      "What happens if we pollute rivers?": "Fish die",
      "Why is the sun important?": "Gives us light",
      "How can we help the planet?": "Pick up trash",
      "What is composting?": "Turning food waste into soil",
      "Why should we turn off the lights?": "Save energy"
    };

    // Set up Firestore document
    await firestore.collection('games').doc('game1').set({
      'logo': 'game_logo.png',
      'name': 'Game Name',
      'description': 'Game Description',
      'bibliography': 'Game Bibliography',
      'tags': ['action', 'adventure'],
      'template': 'quiz',
      'questionsAndOptions': questionsAndOptions,
      'correctAnswers': correctAnswers,
    });

    firestoreService = FirestoreService(firestore: firestore);
  });

  group('getAllGames Tests', () {
    test('getAllGames should return empty list if no games exist', () async {
      firestore = FakeFirebaseFirestore();
      firestoreService = FirestoreService(firestore: firestore);
      final games = await firestoreService.getAllGames();
      expect(games, isEmpty);
    });

    test('getAllGames should return list of games', () async {
      final games = await firestoreService.getAllGames();

      expect(games.length, 1);
      expect(games[0]['imagePath'], 'game_logo.png');
      expect(games[0]['gameTitle'], 'Game Name');
      expect(games[0]['tags'], contains('action'));
      expect(games[0]['tags'], contains('adventure'));
      expect(games[0]['gameId'], 'game1');
    });

    test('getAllGames should handle missing fields safely', () async {
      firestore = FakeFirebaseFirestore();
      firestoreService = FirestoreService(firestore: firestore);
      await firestore.collection('games').add({});

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
        await firestoreService.fetchGameData(gameId: 'non_existing_game');
        fail('Expected an exception to be thrown');
      } catch (e) {
        expect(e.toString(), contains('Game not found'));
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

      final gameData = await firestoreService.fetchGameData(gameId: docRef.id);

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
        await firestoreService.fetchUserData(userId: 'non_existing_user');
        fail('Expected an exception to be thrown');
      } catch (e) {
        expect(e.toString(), contains('User not found'));
      }
    });

    test('fetchUserData should return UserData if exists', () async {
      final docRef = await firestore.collection('users').add({
        'username': 'Lebi',
        'email': 'up202307719@g.uporto.pt',
        'name': 'L',
        'role': 'developer',
        'birthdate': Timestamp.fromDate(DateTime(2000, 1, 1)),
        'img' : 'assets/placeholder.png'
      });

      final userDataFetched = await firestoreService.fetchUserData(userId: docRef.id);

      expect(userDataFetched.username, 'Lebi');
      expect(userDataFetched.email, 'up202307719@g.uporto.pt');
      expect(userDataFetched.name, 'L');
      expect(userDataFetched.role, 'developer');
      expect(userDataFetched.birthdate, DateTime(2000, 1, 1));
      expect(userDataFetched.img, 'assets/placeholder.png');
    });
  });

  group('fetchUserType Tests', () {
    test('fetchUserType returns developer', () async {
      final uid = 'testDeveloper';
      await firestore.collection('users').doc(uid).set({
        'role': 'developer',
      });

      final userRole = await firestoreService.fetchUserType(uid: uid);

      expect(userRole, 'developer');
    });

    test('fetchUserType returns student', () async {
      final uid = 'testStudent';
      await firestore.collection('users').doc(uid).set({
        'role': 'student',
      });

      final userRole = await firestoreService.fetchUserType(uid: uid);

      expect(userRole, 'student');
    });

    test('fetchUserType returns null if user not found', () async {
      final uid = 'non_existing_uid';

      final userRole = await firestoreService.fetchUserType(uid: uid);

      expect(userRole, null);
    });

    test('fetchUserType returns null if role field is null', () async {
      final uid = 'null_role_user';
      await firestore.collection('users').doc(uid).set({
        'role': null,
      });

      final userRole = await firestoreService.fetchUserType(uid: uid);

      expect(userRole, null);
    });

    test('fetchUserType handles unexpected errors', () async {
      final uid = 'invalid_user';
      await firestore.collection('users').doc(uid).set({});
      final userRole = await firestoreService.fetchUserType(uid: uid);

      expect(userRole, null);
    });
  });

  group('getPlayedGames Tests', () {
    test('getPlayedGames should return empty list if no games are played', () async {
      final uid = 'userWithNoGames';
      await firestore.collection('users').doc(uid).set({
        'gamesPlayed': [],
      });
      final games = await firestoreService.getPlayedGames(uid: uid);
      expect(games, isEmpty);
    });

    test('getPlayedGames should return list of games if user has played games', () async {
      final uid = 'userWithGames';

      await firestore.collection('games').doc('game1').set({
        'logo': 'assets/logo.png',
        'name': 'Test Game',
        'tags': ['educational', 'math'],
      });

      await firestore.collection('users').doc(uid).set({
        'gamesPlayed': ['game1'],
      });

      final games = await firestoreService.getPlayedGames(uid: uid);

      expect(games.length, 1);
      expect(games[0]['imagePath'], 'assets/logo.png');
      expect(games[0]['gameTitle'], 'Test Game');
      expect(games[0]['tags'], contains('math'));
    });

    test('getPlayedGames should return empty list if gamesPlayed field is missing', () async {
      final uid = 'userWithoutGamesField';
      await firestore.collection('users').doc(uid).set({});
      final games = await firestoreService.getPlayedGames(uid: uid);

      expect(games, isEmpty);
    });

    test('getPlayedGames should handle invalid data structure in gamesPlayed field', () async {
      final uid = 'userWithInvalidGamesData';
      await firestore.collection('games').doc('game1').set({
        'logo': 'assets/logo.png',
        'name': 'Test Game',
        'tags': ['educational', 'math'],
      });
      await firestore.collection('users').doc(uid).set({'gamesPlayed': [12345],});
      final games = await firestoreService.getPlayedGames(uid: uid);

      expect(games, isEmpty);
    });

    test('getPlayedGames should return empty list if game ID does not exist in the games collection', () async {
      final uid = 'userWithNonExistingGameId';
      await firestore.collection('users').doc(uid).set({
        'gamesPlayed': ['non_existing_game_id'],
      });
      final games = await firestoreService.getPlayedGames(uid: uid);

      expect(games, isEmpty);
    });
  });

  group('updateUserGamesPlayed() Tests', () {
    test('should update the gamesPlayed list correctly', () async {
      final docRef = await firestore.collection('users').add({
        'username': 'Lebi',
        'email': 'up202307719@g.uporto.pt',
        'name': 'L',
        'role': 'developer',
        'birthdate': Timestamp.fromDate(DateTime(2000, 1, 1)),
      });
      String uid = docRef.id;
      String gameId = "myGame";
      await firestoreService.updateUserGamesPlayed(uid: uid, gameId: gameId);
      final docSnapshot = await firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final gamesPlayed = List<String>.from(data?['gamesPlayed'] ?? []);
        final isGamePlayed = gamesPlayed.contains(gameId);
        expect(isGamePlayed, isTrue);
      } else {
        fail("No user data");
      }
    });

    test('should handle error during updateUserGamesPlayed', () async {
      try {
        String uid = "user";
        String gameId = "myGame";
        await firestoreService.updateUserGamesPlayed(uid: uid, gameId: gameId);
        fail("Did not trow error");
      } catch(e) {
        expect(e, isA<FirebaseException>());
      }
    });
  });

  group('registerUser() Tests', () {
    test('registerUser successfully creates a user', () async {
      await firestoreService.setUserInfo(
        uid: 'user1',
        name: 'User One',
        username: 'user1',
        selectedAccountType: 'developer',
        email: 'user1@example.com',
        birthDate: '2000-01-01',
        img: 'assets/placeholder.png'
      );
      final docSnapshot = await firestore.collection('users').doc('user1').get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        expect(data?['name'], 'User One');
        expect(data?['username'], 'user1');
        expect(data?['role'], 'developer');
        expect(data?['email'], 'user1@example.com');
        expect(data?['birthdate'], '2000-01-01');
        expect(data?['img'], 'assets/placeholder.png');
      } else {
        fail("No user data");
      }
    });

    test('registerUser throws exception if no selectedAccountType', () async {
      try {
        await firestoreService.setUserInfo(
          uid: 'user1',
          name: 'User One',
          username: 'user1',
          selectedAccountType: '',
          email: 'user1@example.com',
          birthDate: '2000-01-01',
          img: 'assets/placeholder.png'
        );
        fail("No exception thrown");
      } catch (e) {
        expect(e.toString(), contains("Unable to set user info!"));
      }
    });
  });

  group('createAssignment Tests', () {
    test('createAssignment successfully creates an assignment document', () async {
      await firestore.collection('subjects').doc('ClassA').set({
        'logo': 'game_logo.png',
        'name': 'Sub Name',
        'teacher': 'Me',
        'subjectId': 'ClassA',
      });

      firestoreService = FirestoreService(firestore: firestore);

      String assId = await firestoreService.createAssignment(
        title: 'Assignment 1',
        gameId: 'game1',
        turma: 'ClassA',
        dueDate: '2025-05-01',
      );

      final snapshot = await firestore.collection('assignment').get();
      expect(snapshot.docs.length, 1);

      final assignment = snapshot.docs.first.data();
      expect(assignment['title'], 'Assignment 1');
      expect(assignment['gameId'], 'game1');
      expect(assignment['class'], 'ClassA');
      expect(assignment['dueDate'], '2025-05-01');

      //event
      final eventSnapshot = await firestore.collection('events').get();
      expect(eventSnapshot.docs.length, 1);

      final event = eventSnapshot.docs.first.data();
      expect(event['name'], 'New Assignment!');
      expect(event['className'], 'ClassA');


      //subject
      final subjectSnapshot = await firestore.collection('subjects').get();
      expect(subjectSnapshot.docs.length, 1);

      final subject = subjectSnapshot.docs.first.data();
      expect(subject['assignments'], [assId]);
    });

    test('createAssignment throws exception if no class is selected', () async {
      try {
        await firestoreService.createAssignment(
          title: 'Assignment 2',
          gameId: 'game2',
          turma: '',
          dueDate: '2025-06-01',
        );
        fail('Expected exception was not thrown');
      } catch (e) {
        expect(e.toString(), contains('Unable to create assignment!'));
      }
    });
  });
}
