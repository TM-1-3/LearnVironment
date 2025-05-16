import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:learnvironment/data/subject_data.dart';
import 'package:learnvironment/services/firebase/firestore_service.dart';

class MockFakeFirebaseFirestoreWithErrors extends FakeFirebaseFirestore {
  final bool shouldThrow;

  MockFakeFirebaseFirestoreWithErrors(this.shouldThrow);

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    if (collectionPath == 'users' || collectionPath == "subjects") {
      throw Exception("Error getting document");
    }
    return super.collection(collectionPath);
  }
}

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
      'public': "true"
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

    test('getAllGames should not return private games', () async {
      firestore = FakeFirebaseFirestore();
      firestoreService = FirestoreService(firestore: firestore);
      await firestore.collection('games').doc('game1').set({
        'logo': 'game_logo.png',
        'name': 'Game Name',
        'description': 'Game Description',
        'bibliography': 'Game Bibliography',
        'tags': ['action', 'adventure'],
        'template': 'quiz',
        'questionsAndOptions': '{}',
        'correctAnswers': '{}',
        'public': "false"
      });

      final games = await firestoreService.getAllGames();

      expect(games.length, 0);
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
        'correctAnswers': '{}',
        'public' : 'true'
      });

      final gameData = await firestoreService.fetchGameData(gameId: docRef.id);

      expect(gameData.gameLogo, 'game_logo.png');
      expect(gameData.gameName, 'Game 2');
      expect(gameData.gameDescription, 'Game 2 Description');
      expect(gameData.gameBibliography, 'Game 2 Bibliography');
      expect(gameData.tags, ['strategy', 'simulation']);
      expect(gameData.gameTemplate, 'drag');
      expect(gameData.public, true);
      expect(gameData.correctAnswers, {});
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

    test('get UserId by UserName if exists', () async {
      final docRef = await firestore.collection('users').add({
        'username': 'Lebi',
        'email': 'up202307719@g.uporto.pt',
        'name': 'L',
        'role': 'developer',
        'birthdate': Timestamp.fromDate(DateTime(2000, 1, 1)),
        'img' : 'assets/placeholder.png'
      });

      final userIdFetched = await firestoreService.getUserIdByUserName('Lebi');

      expect(userIdFetched, docRef.id);
    });

    test('check if Student already in Subject', () async {
      final docRef = await firestore.collection('subjects').add({
        'assignments': [],
        'logo': 'assets/placeholder.png',
        'name': 'test',
        'students': ['student'],
        'subjectId': 'something',
        'teacher': 'someone'
      });

      final studentInClass = await firestoreService.checkIfStudentAlreadyInClass(subjectId: docRef.id, studentId: 'student');
      final studentNotInClass = await firestoreService.checkIfStudentAlreadyInClass(subjectId: docRef.id, studentId: 'otherStudent');
      expect(studentInClass, true);
      expect(studentNotInClass, false);
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

  group('getMyGames', () {
    test('should return empty list if user not found for UID', () async {
      firestore = FakeFirebaseFirestore();
      firestoreService = FirestoreService(firestore: firestore);
      final result = await firestoreService.getMyGames(uid: 'id');
      expect(result, []);
    });

    test("should return empty list if 'myGames' field is not found", () async {
      firestore = FakeFirebaseFirestore();
      final docRef = await firestore.collection('users').add({
        'username': 'Lebi',
        'email': 'up202307719@g.uporto.pt',
        'name': 'L',
        'role': 'developer',
        'birthdate': Timestamp.fromDate(DateTime(2000, 1, 1)),
        'img' : 'assets/placeholder.png'
      });
      firestoreService = FirestoreService(firestore: firestore);

      final result = await firestoreService.getMyGames(uid: docRef.id);
      expect(result, []);
    });

    test("should return empty list if 'myGames' is not a list", () async {
      firestore = FakeFirebaseFirestore();
      final docRef = await firestore.collection('users').add({
        'username': 'Lebi',
        'email': 'up202307719@g.uporto.pt',
        'name': 'L',
        'role': 'developer',
        'birthdate': Timestamp.fromDate(DateTime(2000, 1, 1)),
        'img' : 'assets/placeholder.png',
        'myGames' : 'notAList'
      });
      firestoreService = FirestoreService(firestore: firestore);

      final result = await firestoreService.getMyGames(uid: docRef.id);
      expect(result, []);
    });

    test("should return empty list if 'myGames' list is empty", () async {
      firestore = FakeFirebaseFirestore();
      final docRef = await firestore.collection('users').add({
        'username': 'Lebi',
        'email': 'up202307719@g.uporto.pt',
        'name': 'L',
        'role': 'developer',
        'birthdate': Timestamp.fromDate(DateTime(2000, 1, 1)),
        'img' : 'assets/placeholder.png',
        'myGames' : []
      });
      firestoreService = FirestoreService(firestore: firestore);

      final result = await firestoreService.getMyGames(uid: docRef.id);

      // Assert
      expect(result, []);
    });

    test("should return list of game details if 'myGames' contains valid game IDs", () async {
      await firestore.collection('games').doc('game2').set({
        'logo': 'game_logo.png',
        'name': 'Game Name 2',
        'description': 'Game Description',
        'bibliography': 'Game Bibliography',
        'tags': ['action', 'adventure'],
        'template': 'quiz',
        'questionsAndOptions': {},
        'correctAnswers': {},
        'public': "true"
      });

      final docRef = await firestore.collection('users').add({
        'username': 'Lebi',
        'email': 'up202307719@g.uporto.pt',
        'name': 'L',
        'role': 'developer',
        'birthdate': Timestamp.fromDate(DateTime(2000, 1, 1)),
        'img' : 'assets/placeholder.png',
        'myGames' : ['game1', 'game2']
      });
      firestoreService = FirestoreService(firestore: firestore);

      final result = await firestoreService.getMyGames(uid: docRef.id);

      // Assert
      expect(result.length, 2);
      expect(result[0]['gameId'], 'game1');
      expect(result[0]['gameTitle'], 'Game Name');
      expect(result[1]['gameId'], 'game2');
      expect(result[1]['gameTitle'], 'Game Name 2');
    });

    test("should return empty list if Firestore throws an error", () async {
      MockFakeFirebaseFirestoreWithErrors mockFirestore = MockFakeFirebaseFirestoreWithErrors(true);
      FirestoreService firestoreService = FirestoreService(firestore: mockFirestore);

      final result = await firestoreService.getMyGames(uid: "uid");
      expect(result, []);
    });
  });

  group("updateGamePublicStatus", () {
    test('successfully updates public status to true', () async {
      final docRef = await firestore.collection('games').add({
        'logo': 'game_logo.png',
        'name': 'Game Name',
        'description': 'Game Description',
        'bibliography': 'Game Bibliography',
        'tags': ['action', 'adventure'],
        'template': 'quiz',
        'questionsAndOptions': {},
        'correctAnswers': {},
        'public': 'false'
      });
      firestoreService = FirestoreService(firestore: firestore);

      await firestoreService.updateGamePublicStatus(gameId: docRef.id, status: true);

      final updatedDoc = await docRef.get();
      expect(updatedDoc.data()?['public'], 'true');
    });

    test('successfully updates public status to false', () async {
      final docRef = await firestore.collection('games').add({
        'logo': 'game_logo.png',
        'name': 'Game Name',
        'description': 'Game Description',
        'bibliography': 'Game Bibliography',
        'tags': ['action', 'adventure'],
        'template': 'quiz',
        'questionsAndOptions': {},
        'correctAnswers': {},
        'public': 'true'
      });
      firestoreService = FirestoreService(firestore: firestore);

      await firestoreService.updateGamePublicStatus(gameId: docRef.id, status: false);

      final updatedDoc = await docRef.get();
      expect(updatedDoc.data()?['public'], 'false');
    });

    test('does not change value if it is the same as before', () async {
      final docRef = await firestore.collection('games').add({
        'logo': 'game_logo.png',
        'name': 'Game Name',
        'description': 'Game Description',
        'bibliography': 'Game Bibliography',
        'tags': ['action', 'adventure'],
        'template': 'quiz',
        'questionsAndOptions': {},
        'correctAnswers': {},
        'public': 'false'
      });
      firestoreService = FirestoreService(firestore: firestore);

      await firestoreService.updateGamePublicStatus(gameId: docRef.id, status: false);

      final updatedDoc = await docRef.get();
      expect(updatedDoc.data()?['public'], 'false');
    });

    test('throws when update fails', () async {
      MockFakeFirebaseFirestoreWithErrors firestore = MockFakeFirebaseFirestoreWithErrors(true);
      firestoreService = FirestoreService(firestore: firestore);

      expect(
            () async => await firestoreService.updateGamePublicStatus(gameId: 'id', status: true),
        throwsA(isA<FirebaseException>()),
      );
    });

    group('fetchNotifications', () {
      test('fetchNotifications returns correct notifications for student', () async {
        final assRef = await firestore.collection('assignment').add({
          'title': 'Test Assignment',
          'gameId': 'game123',
          'class': 'class1',
          'dueDate': '2025-05-11',
        });

        final docRef = await firestore.collection('users').add({
          'username': 'Lebi',
          'email': 'up202307719@g.uporto.pt',
          'name': 'L',
          'role': 'student',
          'birthdate': Timestamp.fromDate(DateTime(2000, 1, 1)),
          'img' : 'assets/placeholder.png',
          'stClasses' : ['class1'],
          'tClasses' : ['turma']
        });

        await firestore.collection('subjects').doc('class1').set({
          'subjectId': 'class1',
          'name': 'subjectName',
          'logo': 'subjectLogo',
          'teacher': 'id',
          'students': [docRef.id],
          'assignments' : [assRef.id]
        });
        firestoreService = FirestoreService(firestore: firestore);

        final notifications = await firestoreService.fetchNotifications(uid: docRef.id);

        expect(notifications.length, 1);
        expect(notifications.first.notification?.title, 'Assignment: Test Assignment');
        expect(notifications.first.notification?.body, 'Due Date: 2025-05-11');
        expect(notifications.first.data['gameId'], 'game123');
      });

      test('fetchNotifications returns correct notifications for teacher', () async {
        final assRef = await firestore.collection('assignment').add({
          'title': 'Teacher Assignment',
          'gameId': 'game456',
          'class': 'turma',
          'dueDate': '2025-06-01',
        });

        final docRef = await firestore.collection('users').add({
          'username': 'Lebi',
          'email': 'up202307719@g.uporto.pt',
          'name': 'L',
          'role': 'teacher',
          'birthdate': Timestamp.fromDate(DateTime(2000, 1, 1)),
          'img' : 'assets/placeholder.png',
          'stClasses' : [],
          'tClasses' : ['turma']
        });

        await firestore.collection('subjects').doc('turma').set({
          'subjectId': 'turma',
          'name': 'subjectName',
          'logo': 'subjectLogo',
          'teacher': docRef.id,
          'students': [],
          'assignments' : [assRef.id]
        });

        firestoreService = FirestoreService(firestore: firestore);
        final notifications = await firestoreService.fetchNotifications(uid: docRef.id);

        expect(notifications.length, 1);
        expect(notifications.first.notification?.title, 'Assignment: Teacher Assignment');
        expect(notifications.first.notification?.body, 'Due Date: 2025-06-01');
        expect(notifications.first.data['gameId'], 'game456');
      });

      test('fetchNotifications returns empty list if no classes', () async {
        final docRef = await firestore.collection('users').add({
          'username': 'Lebi',
          'email': 'up202307719@g.uporto.pt',
          'name': 'L',
          'role': 'developer',
          'birthdate': Timestamp.fromDate(DateTime(2000, 1, 1)),
          'img' : 'assets/placeholder.png'
        });
        firestoreService = FirestoreService(firestore: firestore);

        final notifications = await firestoreService.fetchNotifications(uid: docRef.id);

        expect(notifications, isEmpty);
      });
    });
  });

  group('FirestoreService.getAllSubjects', () {
    setUp(() async {
      firestore = FakeFirebaseFirestore();

      // Create subjects for teacher "teacher123"
      await firestore.collection('subjects').doc('subject1').set({
        'logo': 'math_logo.png',
        'name': 'Mathematics',
        'teacher': 'teacher123',
      });

      await firestore.collection('subjects').doc('subject2').set({
        'name': 'Science',
        'teacher': 'teacher123',
        // Missing logo
      });

      await firestore.collection('subjects').doc('subject3').set({
        'logo': 'history_logo.png',
        'teacher': 'teacher123',
        // Missing name
      });

      // Subject for a different teacher
      await firestore.collection('subjects').doc('subject4').set({
        'logo': 'art_logo.png',
        'name': 'Art',
        'teacher': 'teacher456',
      });

      firestoreService = FirestoreService(firestore: firestore);
    });

    test('returns all subjects for the given teacherId with correct formatting', () async {
      final result = await firestoreService.getAllSubjects(teacherId: 'teacher123');

      expect(result.length, 3);

      final subject1 = result.firstWhere((s) => s['subjectId'] == 'subject1');
      expect(subject1['subjectName'], 'Mathematics');
      expect(subject1['imagePath'], 'math_logo.png');

      final subject2 = result.firstWhere((s) => s['subjectId'] == 'subject2');
      expect(subject2['subjectName'], 'Science');
      expect(subject2['imagePath'], 'assets/placeholder.png');

      final subject3 = result.firstWhere((s) => s['subjectId'] == 'subject3');
      expect(subject3['subjectName'], 'Default Game Title');
      expect(subject3['imagePath'], 'history_logo.png');
    });

    test('returns an empty list if no subjects match the teacherId', () async {
      final result = await firestoreService.getAllSubjects(teacherId: 'nonexistent_teacher');
      expect(result, isEmpty);
    });

    test('throws and logs error if an exception occurs', () async {
      final faultyService = FirestoreService(firestore: MockFakeFirebaseFirestoreWithErrors(true));
      try {
        await faultyService.getAllSubjects(teacherId: 'teacher123');
        fail('Expected exception was not thrown');
      } catch (e) {
        expect(e.toString(), contains("Error getting document"));
      }
    });
  });

  group('FirestoreService.fetchSubjectData', () {
    setUp(() async {
      firestore = FakeFirebaseFirestore();

      await firestore.collection('subjects').doc('subject123').set({
        'logo': 'math_logo.png',
        'name': 'Mathematics',
        'students': ['student1', 'student2'],
        'assignments': ['assignment1'],
        'teacher': 'teacher123',
      });

      await firestore.collection('subjects').doc('subject_missing_fields').set({
        // No logo, no name, no students, no assignments
        'teacher': 'teacher456',
      });

      firestoreService = FirestoreService(firestore: firestore);
    });

    test('returns SubjectData with correct values for complete document', () async {
      final result = await firestoreService.fetchSubjectData(subjectId: 'subject123');

      expect(result.subjectId, 'subject123');
      expect(result.subjectLogo, 'math_logo.png');
      expect(result.subjectName, 'Mathematics');
      expect(result.students, ['student1', 'student2']);
      expect(result.assignments, ['assignment1']);
      expect(result.teacher, 'teacher123');
    });

    test('returns SubjectData with fallback/default values for missing fields', () async {
      final result = await firestoreService.fetchSubjectData(subjectId: 'subject_missing_fields');

      expect(result.subjectId, 'subject_missing_fields');
      expect(result.subjectLogo, 'assets/placeholder.png');
      expect(result.subjectName, 'Unknown Name');
      expect(result.students, []);
      expect(result.assignments, []);
      expect(result.teacher, 'teacher456');
    });

    test('throws an exception when subject does not exist', () async {
      expect(
            () async => await firestoreService.fetchSubjectData(subjectId: 'nonexistent'),
        throwsA(predicate((e) =>
        e is Exception &&
            e.toString().contains("Subject not found in Firestore for ID: nonexistent"))),
      );
    });

    test('throws and logs error if Firestore fails unexpectedly', () async {
      final faultyService = FirestoreService(firestore: MockFakeFirebaseFirestoreWithErrors(true));
      try {
        await faultyService.fetchSubjectData(subjectId: 'subject123');
        fail('Expected exception was not thrown');
      } catch (e) {
        expect(e.toString(), contains("Error getting document"));
      }
    });
  });

  group('FirestoreService.addSubjectData', () {
    late String testUid = "123";
    setUp(() async {
      firestore = FakeFirebaseFirestore();

      await firestore.collection('users').doc(testUid).set({
        'name': 'Test Teacher',
        'tClasses': ['old_subject'],
      });

      firestoreService = FirestoreService(firestore: firestore);
    });

    test('adds subject to Firestore and updates user tClasses list', () async {
      final subject = SubjectData(
        subjectId: 'subject001',
        subjectName: 'Science',
        subjectLogo: 'science_logo.png',
        students: ['student1', 'student2'],
        assignments: ['assignment1'],
        teacher: testUid,
      );

      await firestoreService.addSubjectData(subject: subject, uid: testUid);

      final subjectSnapshot = await firestore.collection('subjects').doc('subject001').get();
      expect(subjectSnapshot.exists, isTrue);

      final data = subjectSnapshot.data()!;
      expect(data['name'], 'Science');
      expect(data['logo'], 'science_logo.png');
      expect(data['teacher'], testUid);
      expect(data['students'], ['student1', 'student2']);
      expect(data['assignments'], ['assignment1']);

      final userSnapshot = await firestore.collection('users').doc(testUid).get();
      final userData = userSnapshot.data()!;
      expect(userData['tClasses'], contains('subject001'));
      expect(userData['tClasses'].first, 'subject001');
    });

    test('adds subject for user with no tClasses field', () async {
      const uid = 'new_teacher';

      await firestore.collection('users').doc(uid).set({
        'name': 'New Teacher',
        // No tClasses field
      });

      final subject = SubjectData(
        subjectId: 'subject002',
        subjectName: 'Math',
        subjectLogo: 'math_logo.png',
        students: [],
        assignments: [],
        teacher: uid,
      );

      await firestoreService.addSubjectData(subject: subject, uid: uid);

      final userSnapshot = await firestore.collection('users').doc(uid).get();
      final userData = userSnapshot.data()!;
      expect(userData['tClasses'], ['subject002']);
    });

    test('throws and logs error if user update fails', () async {
      final faultySubject = SubjectData(
        subjectId: 'subject003',
        subjectName: 'History',
        subjectLogo: 'history_logo.png',
        students: [],
        assignments: [],
        teacher: testUid,
      );

      // Delete the user document to force update failure
      await firestore.collection('users').doc(testUid).delete();

      expect(() async => await firestoreService.addSubjectData(subject: faultySubject, uid: testUid),
        throwsA(isA<FirebaseException>()),
      );
    });
  });

  group('FirestoreService.deleteSubject', () {
    const String testUid = 'user123';
    const String subjectId = 'subjectABC';

    setUp(() async {
      firestore = FakeFirebaseFirestore();

      await firestore.collection('subjects').doc(subjectId).set({
        'name': 'Science',
        'teacher': testUid,
      });

      await firestore.collection('users').doc(testUid).set({
        'name': 'Test User',
        'stClasses': ['subjectABC'],
        'tClasses': ['subjectABC', 'class3'],
      });

      firestoreService = FirestoreService(firestore: firestore);
    });

    test('deletes the subject and updates all related user class lists', () async {
      await firestoreService.deleteSubject(subjectId: subjectId, uid: testUid);

      // Subject should be deleted
      final subjectSnapshot = await firestore.collection('subjects').doc(subjectId).get();
      expect(subjectSnapshot.exists, isFalse);

      // User's class fields should no longer contain subjectId
      final userSnapshot = await firestore.collection('users').doc(testUid).get();
      final userData = userSnapshot.data()!;

      expect(userData['stClasses'], isNot(contains(subjectId)));
      expect(userData['tClasses'], isNot(contains(subjectId)));

      expect(userData['tClasses'], contains('class3'));
    });

    test('handles user with no class lists gracefully', () async {
      const uid = 'user456';
      await firestore.collection('subjects').doc('subjectXYZ').set({
        'name': 'Math',
        'teacher': uid,
      });

      await firestore.collection('users').doc(uid).set({
        'name': 'No Classes User'
      });

      await firestoreService.deleteSubject(subjectId: 'subjectXYZ', uid: uid);

      final userSnapshot = await firestore.collection('users').doc(uid).get();
      final userData = userSnapshot.data()!;

      expect(userData['stClasses'], []);
      expect(userData['tClasses'], []);
    });

    test('throws and logs error if subject deletion fails', () async {
      final faultyService = FirestoreService(firestore: MockFakeFirebaseFirestoreWithErrors(true));
      try {
        await faultyService.deleteSubject(subjectId: 'fakeId', uid: 'fakeUser');
        fail('Expected exception was not thrown');
      } catch (e) {
        expect(e.toString(), contains("Error getting document"));
      }
    });
  });
}

/* Missing tests:
- addStudentToSubject
- removeStudentFromSubject
- fetchAssignmentData
- deleteAssignment
- getAllAssignments
 */