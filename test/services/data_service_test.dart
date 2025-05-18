import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/assignment_data.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/data/subject_data.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/firebase/firestore_service.dart';
import 'package:learnvironment/services/cache/user_cache_service.dart';
import 'package:learnvironment/services/cache/game_cache_service.dart';
import 'package:learnvironment/services/cache/subject_cache_service.dart';
import 'package:learnvironment/services/cache/assignment_cache_service.dart';
import 'package:provider/provider.dart';

import 'data_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FirestoreService>(),
  MockSpec<UserCacheService>(),
  MockSpec<GameCacheService>(),
  MockSpec<SubjectCacheService>(),
  MockSpec<AssignmentCacheService>(),
])

void main() {
  late MockFirestoreService mockFirestoreService;
  late MockUserCacheService mockUserCacheService;
  late MockGameCacheService mockGameCacheService;
  late MockSubjectCacheService mockSubjectCacheService;
  late MockAssignmentCacheService mockAssignmentCacheService;

  setUp(() {
    // Initialize the mock services
    mockFirestoreService = MockFirestoreService();
    mockUserCacheService = MockUserCacheService();
    mockGameCacheService = MockGameCacheService();
    mockSubjectCacheService = MockSubjectCacheService();
    mockAssignmentCacheService = MockAssignmentCacheService();
  });

  // Helper function to create a widget that provides the necessary services
  Widget createTestableWidget(Widget child) {
    return MultiProvider(
      providers: [
        Provider<FirestoreService>.value(value: mockFirestoreService),
        Provider<UserCacheService>.value(value: mockUserCacheService),
        Provider<GameCacheService>.value(value: mockGameCacheService),
        Provider<SubjectCacheService>.value(value: mockSubjectCacheService),
        Provider<AssignmentCacheService>.value(value: mockAssignmentCacheService),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('checkIfUsernameAlreadyExists', () {
    testWidgets('returns true if username exists', (WidgetTester tester) async {
      when(mockFirestoreService.checkIfUsernameAlreadyExists('existingUsername'))
          .thenAnswer((_) async => true);

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      final result = await state.getDataService().checkIfUsernameAlreadyExists('existingUsername');

      expect(result, isTrue);
      verify(mockFirestoreService.checkIfUsernameAlreadyExists('existingUsername')).called(1);
      verifyNoMoreInteractions(mockFirestoreService);
    });

    testWidgets('returns false if username does not exist', (WidgetTester tester) async {
      when(mockFirestoreService.checkIfUsernameAlreadyExists('newUsername'))
          .thenAnswer((_) async => false);

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      final result = await state.getDataService().checkIfUsernameAlreadyExists('newUsername');

      expect(result, isFalse);
      verify(mockFirestoreService.checkIfUsernameAlreadyExists('newUsername')).called(1);
      verifyNoMoreInteractions(mockFirestoreService);
    });
  });

  group('getUserIdByUserName', () {
    testWidgets('returns user ID if username exists', (WidgetTester tester) async {
      // Arrange
      when(mockFirestoreService.getUserIdByUserName('john_doe'))
          .thenAnswer((_) async => 'user_123');

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      // Access DataService from widget's state
      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );

      // Act
      final result = await state.getDataService().getUserIdByUserName('john_doe');

      // Assert
      expect(result, equals('user_123'));
      verify(mockFirestoreService.getUserIdByUserName('john_doe')).called(1);
      verifyNoMoreInteractions(mockFirestoreService);
    });

    testWidgets('returns null if username does not exist', (WidgetTester tester) async {
      // Arrange
      when(mockFirestoreService.getUserIdByUserName('ghost_user'))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      // Access DataService from widget's state
      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );

      // Act
      final result = await state.getDataService().getUserIdByUserName('ghost_user');

      // Assert
      expect(result, isNull);
      verify(mockFirestoreService.getUserIdByUserName('ghost_user')).called(1);
      verifyNoMoreInteractions(mockFirestoreService);
    });
  });

  group('updateUserGamesPlayed', () {
    const String userId = 'user_123';
    const String gameId = 'game_456';

    testWidgets('updates Firestore and cache when cached user matches', (WidgetTester tester) async {
      final UserData userData = UserData(id: userId, username: 'username', email: 'email', name: 'name', role: 'teacher', birthdate: DateTime(2000, 1, 1, 0, 0, 0, 0, 0), gamesPlayed: [], myGames: [], img: '', tClasses: [], stClasses: []);
      // Arrange: mock Firestore and cache behavior
      when(mockFirestoreService.updateUserGamesPlayed(uid: userId, gameId: gameId))
          .thenAnswer((_) async => {});
      when(mockUserCacheService.getCachedUserData())
          .thenAnswer((_) async => userData);
      when(mockUserCacheService.updateCachedGamesPlayed(gameId))
          .thenAnswer((_) async => {});

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );

      // Act
      await state.getDataService().updateUserGamesPlayed(userId: userId, gameId: gameId);

      // Assert
      verify(mockFirestoreService.updateUserGamesPlayed(uid: userId, gameId: gameId)).called(1);
      verify(mockUserCacheService.getCachedUserData()).called(1);
      verify(mockUserCacheService.updateCachedGamesPlayed(gameId)).called(1);
      verifyNoMoreInteractions(mockFirestoreService);
      verifyNoMoreInteractions(mockUserCacheService);
    });

    testWidgets('updates Firestore but not cache if cached user does not match', (WidgetTester tester) async {
      final UserData userData = UserData(id: "different_user", username: 'username', email: 'email', name: 'name', role: 'teacher', birthdate: DateTime(2000, 1, 1, 0, 0, 0, 0, 0), gamesPlayed: [], myGames: [], img: '', tClasses: [], stClasses: []);
      // Arrange
      when(mockFirestoreService.updateUserGamesPlayed(uid: userId, gameId: gameId))
          .thenAnswer((_) async => {});
      when(mockUserCacheService.getCachedUserData())
          .thenAnswer((_) async => userData);

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );

      // Act
      await state.getDataService().updateUserGamesPlayed(userId: userId, gameId: gameId);

      // Assert
      verify(mockFirestoreService.updateUserGamesPlayed(uid: userId, gameId: gameId)).called(1);
      verify(mockUserCacheService.getCachedUserData()).called(1);
      verifyNever(mockUserCacheService.updateCachedGamesPlayed(any));
      verifyNoMoreInteractions(mockFirestoreService);
      verifyNoMoreInteractions(mockUserCacheService);
    });

    testWidgets('throws exception if Firestore update fails', (WidgetTester tester) async {
      // Arrange
      when(mockFirestoreService.updateUserGamesPlayed(uid: userId, gameId: gameId))
          .thenThrow(Exception('Firestore failure'));

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );

      // Act & Assert
      expect(
            () async => await state.getDataService().updateUserGamesPlayed(userId: userId, gameId: gameId),
        throwsA(isA<Exception>()),
      );

      verify(mockFirestoreService.updateUserGamesPlayed(uid: userId, gameId: gameId)).called(1);
      verifyNever(mockUserCacheService.getCachedUserData());
      verifyNoMoreInteractions(mockFirestoreService);
      verifyZeroInteractions(mockUserCacheService);
    });
  });

  group('getUserData', () {
    const userId = 'user_123';
    final UserData userData = UserData(id: userId, username: 'username', email: 'email', name: 'name', role: 'teacher', birthdate: DateTime(2000, 1, 1, 0, 0, 0, 0, 0), gamesPlayed: [], myGames: [], img: '', tClasses: [], stClasses: []);

    testWidgets('returns cached user if it matches userId', (WidgetTester tester) async {
      final cachedUser = userData;

      when(mockUserCacheService.getCachedUserData())
          .thenAnswer((_) async => cachedUser);

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );

      final result = await state.getDataService().getUserData(userId: userId);

      expect(result, cachedUser);
      verify(mockUserCacheService.getCachedUserData()).called(1);
      verifyNever(mockFirestoreService.fetchUserData(userId: anyNamed('userId')));
      verifyNoMoreInteractions(mockUserCacheService);
      verifyZeroInteractions(mockFirestoreService);
    });

    testWidgets('fetches from Firestore and caches if cache is null', (WidgetTester tester) async {
      final firestoreUser = userData;

      when(mockUserCacheService.getCachedUserData())
          .thenAnswer((_) async => null);
      when(mockFirestoreService.fetchUserData(userId: userId))
          .thenAnswer((_) async => firestoreUser);
      when(mockUserCacheService.cacheUserData(firestoreUser))
          .thenAnswer((_) async => {});

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );

      final result = await state.getDataService().getUserData(userId: userId);

      expect(result, firestoreUser);
      verify(mockUserCacheService.getCachedUserData()).called(1);
      verify(mockFirestoreService.fetchUserData(userId: userId)).called(1);
      verify(mockUserCacheService.cacheUserData(firestoreUser)).called(1);
      verifyNoMoreInteractions(mockUserCacheService);
      verifyNoMoreInteractions(mockFirestoreService);
    });

    testWidgets('fetches from Firestore and caches if cached user has different id', (WidgetTester tester) async {
      final cachedUser = UserData(id: "other_id", username: 'username', email: 'email', name: 'name', role: 'teacher', birthdate: DateTime(2000, 1, 1, 0, 0, 0, 0, 0), gamesPlayed: [], myGames: [], img: '', tClasses: [], stClasses: []);
      final firestoreUser = userData;

      when(mockUserCacheService.getCachedUserData())
          .thenAnswer((_) async => cachedUser);
      when(mockFirestoreService.fetchUserData(userId: userId))
          .thenAnswer((_) async => firestoreUser);
      when(mockUserCacheService.cacheUserData(firestoreUser))
          .thenAnswer((_) async => {});

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );

      final result = await state.getDataService().getUserData(userId: userId);

      expect(result, firestoreUser);
      verify(mockUserCacheService.getCachedUserData()).called(1);
      verify(mockFirestoreService.fetchUserData(userId: userId)).called(1);
      verify(mockUserCacheService.cacheUserData(firestoreUser)).called(1);
      verifyNoMoreInteractions(mockUserCacheService);
      verifyNoMoreInteractions(mockFirestoreService);
    });

    testWidgets('returns null and logs error on exception', (WidgetTester tester) async {
      when(mockUserCacheService.getCachedUserData())
          .thenThrow(Exception('Cache error'));

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );

      final result = await state.getDataService().getUserData(userId: userId);

      expect(result, isNull);
      verify(mockUserCacheService.getCachedUserData()).called(1);
      verifyZeroInteractions(mockFirestoreService);
    });
  });

  group('deleteAccount', () {
    const uid = 'user_123';

    testWidgets('calls deleteAccount and clears cache on success', (WidgetTester tester) async {
      // Arrange
      when(mockFirestoreService.deleteAccount(uid: uid)).thenAnswer((_) async {});
      when(mockUserCacheService.clearUserCache()).thenAnswer((_) async {});

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );

      // Act
      await state.getDataService().deleteAccount(uid: uid);

      // Assert
      verify(mockFirestoreService.deleteAccount(uid: uid)).called(1);
      verify(mockUserCacheService.clearUserCache()).called(1);
      verifyNoMoreInteractions(mockFirestoreService);
      verifyNoMoreInteractions(mockUserCacheService);
    });

    testWidgets('rethrows exception if Firestore deletion fails', (WidgetTester tester) async {
      // Arrange
      when(mockFirestoreService.deleteAccount(uid: uid))
          .thenThrow(Exception('Firestore delete failed'));

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );

      // Act & Assert
      expect(
            () async => await state.getDataService().deleteAccount(uid: uid),
        throwsA(isA<Exception>()),
      );

      verify(mockFirestoreService.deleteAccount(uid: uid)).called(1);
      verifyNever(mockUserCacheService.clearUserCache());
      verifyNoMoreInteractions(mockFirestoreService);
      verifyZeroInteractions(mockUserCacheService);
    });

    testWidgets('rethrows exception if clearing cache fails', (WidgetTester tester) async {
      // Arrange
      when(mockFirestoreService.deleteAccount(uid: uid)).thenAnswer((_) async {});
      when(mockUserCacheService.clearUserCache())
          .thenThrow(Exception('Cache clear failed'));

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );

      // Act & Assert
      expect(
            () => state.getDataService().deleteAccount(uid: uid),
        throwsA(isA<Exception>()),
      );

      await tester.pump();

      verify(mockFirestoreService.deleteAccount(uid: uid)).called(1);
      verify(mockUserCacheService.clearUserCache()).called(1);
      verifyNoMoreInteractions(mockFirestoreService);
      verifyNoMoreInteractions(mockUserCacheService);
    });
  });

  group('updateUserProfile', () {
    const uid = 'user123';
    const name = 'Test Name';
    const username = 'test_user';
    const email = 'test@example.com';
    const birthDate = '2000-01-01';
    const role = 'student';
    const img = 'http://image.url/avatar.png';

    final gamesPlayed = ['game1', 'game2'];
    final myGames = ['myGame1'];
    final stClasses = ['class1'];
    final tClasses = ['class2'];

    setUp(() {
      // Return fixed lists when any cache method is called
      when(mockUserCacheService.getCachedGamesPlayed()).thenAnswer((_) async => gamesPlayed);
      when(mockUserCacheService.getMyGames()).thenAnswer((_) async => myGames);
      when(mockUserCacheService.getCachedClasses(type: 'stClasses')).thenAnswer((_) async => stClasses);
      when(mockUserCacheService.getCachedClasses(type: 'tClasses')).thenAnswer((_) async => tClasses);
      when(mockUserCacheService.clearUserCache()).thenAnswer((_) async => {});
      when(mockUserCacheService.cacheUserData(any)).thenAnswer((_) async => {});
      when(mockFirestoreService.setUserInfo(
        uid: anyNamed('uid'),
        name: anyNamed('name'),
        email: anyNamed('email'),
        username: anyNamed('username'),
        birthDate: anyNamed('birthDate'),
        selectedAccountType: anyNamed('selectedAccountType'),
        img: anyNamed('img'),
        stClasses: anyNamed('stClasses'),
        tClasses: anyNamed('tClasses'),
        gamesPlayed: anyNamed('gamesPlayed'),
        myGames: anyNamed('myGames'),
      )).thenAnswer((_) async => {});
    });

    testWidgets('updates user profile successfully and caches updated user', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );

      // Act
      await state.getDataService().updateUserProfile(
        uid: uid,
        name: name,
        username: username,
        email: email,
        birthDate: birthDate,
        role: role,
        img: img,
      );

      // Assert all the expected calls
      verify(mockUserCacheService.getCachedGamesPlayed()).called(1);
      verify(mockUserCacheService.getMyGames()).called(1);
      verify(mockUserCacheService.getCachedClasses(type: 'stClasses')).called(1);
      verify(mockUserCacheService.getCachedClasses(type: 'tClasses')).called(1);
      verify(mockFirestoreService.setUserInfo(
        uid: uid,
        name: name,
        email: email,
        username: username,
        birthDate: birthDate,
        selectedAccountType: role,
        img: img,
        stClasses: stClasses,
        tClasses: tClasses,
        gamesPlayed: gamesPlayed,
        myGames: myGames,
      )).called(1);
      verify(mockUserCacheService.clearUserCache()).called(1);
      verify(mockUserCacheService.cacheUserData(any)).called(1);

      verifyNoMoreInteractions(mockFirestoreService);
      verifyNoMoreInteractions(mockUserCacheService);
    });

    testWidgets('handles errors internally without throwing', (WidgetTester tester) async {
      // Simulate failure during Firestore set
      when(mockFirestoreService.setUserInfo(
        uid: anyNamed('uid'),
        name: anyNamed('name'),
        email: anyNamed('email'),
        username: anyNamed('username'),
        birthDate: anyNamed('birthDate'),
        selectedAccountType: anyNamed('selectedAccountType'),
        img: anyNamed('img'),
        stClasses: anyNamed('stClasses'),
        tClasses: anyNamed('tClasses'),
        gamesPlayed: anyNamed('gamesPlayed'),
        myGames: anyNamed('myGames'),
      )).thenThrow(Exception('Firestore failure'));

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );

      // Act & Assert: should not throw despite the failure
      await state.getDataService().updateUserProfile(
        uid: uid,
        name: name,
        username: username,
        email: email,
        birthDate: birthDate,
        role: role,
        img: img,
      );

      verify(mockFirestoreService.setUserInfo(
        uid: uid,
        name: name,
        email: email,
        username: username,
        birthDate: birthDate,
        selectedAccountType: role,
        img: img,
        stClasses: stClasses,
        tClasses: tClasses,
        gamesPlayed: gamesPlayed,
        myGames: myGames,
      )).called(1);
    });
  });

  group('getGameData', () {
    const gameId = 'game_abc';
    GameData gameData = GameData(gameLogo: "", gameName: "", gameBibliography: "", gameDescription: "", gameTemplate: "drag", tips: {}, correctAnswers: {}, tags: [], documentName: gameId, public: true);

    testWidgets('returns cached game data if available', (WidgetTester tester) async {
      final cachedGame = gameData;

      when(mockGameCacheService.getCachedGameData(gameId))
          .thenAnswer((_) async => cachedGame);

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );

      final result = await state.getDataService().getGameData(gameId: gameId);

      expect(result, cachedGame);
      verify(mockGameCacheService.getCachedGameData(gameId)).called(1);
      verifyNever(mockFirestoreService.fetchGameData(gameId: gameId));
      verifyNever(mockGameCacheService.cacheGameData(any));
      verifyNoMoreInteractions(mockGameCacheService);
      verifyZeroInteractions(mockFirestoreService);
    });

    testWidgets('fetches from Firestore and caches if not in cache', (WidgetTester tester) async {
      final freshGame = gameData;

      when(mockGameCacheService.getCachedGameData(gameId))
          .thenAnswer((_) async => null);
      when(mockFirestoreService.fetchGameData(gameId: gameId))
          .thenAnswer((_) async => freshGame);
      when(mockGameCacheService.cacheGameData(freshGame))
          .thenAnswer((_) async => {});

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );

      final result = await state.getDataService().getGameData(gameId: gameId);

      expect(result, freshGame);
      verify(mockGameCacheService.getCachedGameData(gameId)).called(1);
      verify(mockFirestoreService.fetchGameData(gameId: gameId)).called(1);
      verify(mockGameCacheService.cacheGameData(freshGame)).called(1);
      verifyNoMoreInteractions(mockGameCacheService);
      verifyNoMoreInteractions(mockFirestoreService);
    });

    testWidgets('returns null and logs error on exception', (WidgetTester tester) async {
      when(mockGameCacheService.getCachedGameData(gameId))
          .thenThrow(Exception('Cache fail'));

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );

      final result = await state.getDataService().getGameData(gameId: gameId);

      expect(result, isNull);
      verify(mockGameCacheService.getCachedGameData(gameId)).called(1);
      verifyZeroInteractions(mockFirestoreService);
    });
  });

  group('getAllGames', () {
    GameData gameData = GameData(gameLogo: "logo.png", gameName: "Trivia Quest", gameBibliography: "", gameDescription: "", gameTemplate: "drag", tips: {}, correctAnswers: {}, tags: ['fun', 'trivia'], documentName: "game123", public: true);

    testWidgets('returns public cached games if available', (WidgetTester tester) async {
      final publicGame = gameData;

      when(mockGameCacheService.getCachedGameIds()).thenAnswer((_) async => ['game123']);
      when(mockGameCacheService.getCachedGameData('game123')).thenAnswer((_) async => publicGame);

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));
      final result = await state.getDataService().getAllGames();

      expect(result.length, 1);
      expect(result.first['gameTitle'], 'Trivia Quest');
      verify(mockGameCacheService.getCachedGameIds()).called(1);
      verify(mockGameCacheService.getCachedGameData('game123')).called(1);
      verifyZeroInteractions(mockFirestoreService);
    });

    testWidgets('fetches from Firestore if no valid cached games', (WidgetTester tester) async {
      // Simulate no valid cached games
      when(mockGameCacheService.getCachedGameIds()).thenAnswer((_) async => []);
      when(mockFirestoreService.getAllGames()).thenAnswer((_) async => [
        {
          'gameId': 'fresh1',
          'gameTitle': 'Fresh Game',
          'tags': ['new'],
          'gameLogo': 'fresh_logo.png'
        }
      ]);

      GameData gameData = GameData(gameLogo: "fresh_logo.png", gameName: "Fresh Game", gameBibliography: "", gameDescription: "", gameTemplate: "drag", tips: {}, correctAnswers: {}, tags: ['new'], documentName: "fresh1", public: true);
      final freshGameData = gameData;
      when(mockFirestoreService.fetchGameData(gameId: 'fresh1')).thenAnswer((_) async => freshGameData);
      when(mockGameCacheService.cacheGameData(freshGameData)).thenAnswer((_) async => {});

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));
      final result = await state.getDataService().getAllGames();

      expect(result.length, 1);
      expect(result.first['gameId'], 'fresh1');
      verify(mockGameCacheService.getCachedGameIds()).called(1);
      verify(mockFirestoreService.getAllGames()).called(1);
      verify(mockFirestoreService.fetchGameData(gameId: 'fresh1')).called(1);
      verify(mockGameCacheService.cacheGameData(freshGameData)).called(1);
    });

    testWidgets('returns empty list on error', (WidgetTester tester) async {
      when(mockGameCacheService.getCachedGameIds()).thenThrow(Exception('Cache fail'));

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));
      final result = await state.getDataService().getAllGames();

      expect(result, isEmpty);
      verify(mockGameCacheService.getCachedGameIds()).called(1);
    });
  });

  group('createGame', () {
    const uid = 'user123';
    late GameData gameData;

    setUp(() {
      gameData = GameData(gameLogo: "logo.png", gameName: "Trivia Quest", gameBibliography: "", gameDescription: "", gameTemplate: "drag", tips: {}, correctAnswers: {}, tags: ['fun', 'trivia'], documentName: "game_abc", public: true);
    });

    testWidgets('successfully creates game and updates cache', (WidgetTester tester) async {
      when(mockFirestoreService.createGame(uid: uid, game: gameData))
          .thenAnswer((_) async {});
      when(mockUserCacheService.createGame(uid: uid, gameId: 'game_abc'))
          .thenAnswer((_) async {});
      when(mockGameCacheService.cacheGameData(gameData))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));

      await state.getDataService().createGame(uid: uid, game: gameData);

      verify(mockFirestoreService.createGame(uid: uid, game: gameData)).called(1);
      verify(mockUserCacheService.createGame(uid: uid, gameId: 'game_abc')).called(1);
      verify(mockGameCacheService.cacheGameData(gameData)).called(1);
      verifyNoMoreInteractions(mockFirestoreService);
      verifyNoMoreInteractions(mockUserCacheService);
      verifyNoMoreInteractions(mockGameCacheService);
    });

    testWidgets('rethrows exception if Firestore call fails', (WidgetTester tester) async {
      when(mockFirestoreService.createGame(uid: uid, game: gameData))
          .thenThrow(Exception('Firestore failed'));

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));

      expect(
            () async => await state.getDataService().createGame(uid: uid, game: gameData),
        throwsA(isA<Exception>()),
      );

      verify(mockFirestoreService.createGame(uid: uid, game: gameData)).called(1);
      verifyZeroInteractions(mockUserCacheService);
      verifyZeroInteractions(mockGameCacheService);
    });
  });

  group('getMyGames', () {
    const uid = 'user123';
    late GameData gameData;

    setUp(() {
      gameData = GameData(gameLogo: "game_logo.png", gameName: "Amazing Game", gameBibliography: "", gameDescription: "", gameTemplate: "drag", tips: {}, correctAnswers: {}, tags: ['adventure', 'multiplayer'], documentName: "game123", public: true);
    });

    testWidgets('returns cached games if available', (WidgetTester tester) async {
      // Simulate cached games
      when(mockUserCacheService.getMyGames()).thenAnswer((_) async => ['game123']);
      when(mockGameCacheService.getCachedGameData('game123')).thenAnswer((_) async => gameData);

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));

      final result = await state.getDataService().getMyGames(uid: uid);

      expect(result.length, 1);
      expect(result.first['gameTitle'], 'Amazing Game');
      verify(mockUserCacheService.getMyGames()).called(1);
      verify(mockGameCacheService.getCachedGameData('game123')).called(1);
      verifyNoMoreInteractions(mockFirestoreService);
    });

    testWidgets('falls back to Firestore if game cache is empty', (WidgetTester tester) async {
      // Simulate empty cache and Firestore response
      when(mockUserCacheService.getMyGames()).thenAnswer((_) async => ['game123']);
      when(mockGameCacheService.getCachedGameData('game123'))
          .thenAnswer((_) async => null);
      when(mockFirestoreService.fetchGameData(gameId: 'game123'))
          .thenAnswer((_) async => gameData);

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));

      final result = await state.getDataService().getMyGames(uid: uid);

      expect(result.length, 1);
      expect(result.first['gameTitle'], 'Amazing Game');
      verify(mockUserCacheService.getMyGames()).called(1);
      verify(mockFirestoreService.fetchGameData(gameId: 'game123')).called(1);
      verify(mockGameCacheService.getCachedGameData('game123')).called(1);
      verify(mockGameCacheService.cacheGameData(gameData)).called(1);
    });

    testWidgets('falls back to Firestore if user cache is empty', (WidgetTester tester) async {
      // Simulate empty cache and Firestore response
      when(mockUserCacheService.getMyGames()).thenAnswer((_) async => []);
      when(mockFirestoreService.getMyGames(uid: uid))
          .thenAnswer((_) async => [
        {'gameId': 'game123',
        'gameTitle': 'Amazing Game'}
      ]);

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));

      final result = await state.getDataService().getMyGames(uid: uid);

      expect(result.length, 1);
      expect(result.first['gameTitle'], 'Amazing Game');
      verify(mockUserCacheService.getMyGames()).called(1);
      verify(mockFirestoreService.getMyGames(uid: uid)).called(1);
    });

    testWidgets('returns empty list on error', (WidgetTester tester) async {
      // Simulate an error
      when(mockUserCacheService.getMyGames()).thenThrow(Exception('Cache failed'));

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));

      final result = await state.getDataService().getMyGames(uid: uid);

      expect(result, isEmpty);
      verify(mockUserCacheService.getMyGames()).called(1);
      verifyZeroInteractions(mockFirestoreService);
      verifyZeroInteractions(mockGameCacheService);
    });
  });

  group('updateGamePublicStatus', () {
    const gameId = 'game123';
    const status = true;

    setUp(() {
      // Reset the mock services for each test
      when(mockFirestoreService.updateGamePublicStatus(gameId: gameId, status: status))
          .thenAnswer((_) async {});
      when(mockGameCacheService.updateGamePublicStatus(gameId: gameId, status: status))
          .thenAnswer((_) async {});
    });

    testWidgets('should update Firestore and game cache successfully', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));

      // Act
      await state.getDataService().updateGamePublicStatus(gameId: gameId, status: status);

      // Assert
      verify(mockFirestoreService.updateGamePublicStatus(gameId: gameId, status: status)).called(1);
      verify(mockGameCacheService.updateGamePublicStatus(gameId: gameId, status: status)).called(1);
      verifyNoMoreInteractions(mockFirestoreService);
      verifyNoMoreInteractions(mockGameCacheService);
    });

    testWidgets('should throw an exception if Firestore update fails', (WidgetTester tester) async {
      // Arrange: Simulate Firestore failure
      when(mockFirestoreService.updateGamePublicStatus(gameId: gameId, status: status))
          .thenThrow(Exception('Firestore update failed'));

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));

      // Act & Assert
      expect(
            () => state.getDataService().updateGamePublicStatus(gameId: gameId, status: status),
        throwsA(isA<Exception>()),
      );

      verify(mockFirestoreService.updateGamePublicStatus(gameId: gameId, status: status)).called(1);
      verifyNoMoreInteractions(mockGameCacheService);  // Ensure cache is not updated if Firestore fails
    });

    testWidgets('should throw an exception if cache update fails', (WidgetTester tester) async {
      // Arrange: Simulate cache update failure
      when(mockGameCacheService.updateGamePublicStatus(gameId: gameId, status: status))
          .thenThrow(Exception('Cache update failed'));

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));

      // Act & Assert
      expect(
            () => state.getDataService().updateGamePublicStatus(gameId: gameId, status: status),
        throwsA(isA<Exception>()),
      );

      await tester.pump();

      verify(mockFirestoreService.updateGamePublicStatus(gameId: gameId, status: status)).called(1);
      verify(mockGameCacheService.updateGamePublicStatus(gameId: gameId, status: status)).called(1);
    });
  });

  group('getPlayedGames', () {
    const userId = 'user123';
    const gameId = 'game123';

    setUp(() {
      // Reset mocks for each test
      when(mockUserCacheService.getCachedGamesPlayed()).thenAnswer((_) async => ['game123']);
      when(mockFirestoreService.getPlayedGames(uid: userId)).thenAnswer((_) async => [
        {'gameId': gameId, 'gameTitle': 'Game 1', 'tags': ['Action', 'Adventure'], 'imagePath': 'image1.jpg'}
      ]);
      when(mockGameCacheService.getCachedGameData(gameId)).thenAnswer((_) async => GameData(
        gameLogo: 'image1.jpg',
        gameName: 'Game 1',
        tags: ['Action', 'Adventure'],
        documentName: gameId,
        public: true,
        gameDescription: '',
        gameBibliography: '',
        gameTemplate: '',
        correctAnswers: {}, tips: {},
      ));
    });

    testWidgets('should load games from cache', (WidgetTester tester) async {
      // Arrange: Mock the cache with game IDs
      when(mockUserCacheService.getCachedGamesPlayed()).thenAnswer((_) async => [gameId]);

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));

      // Act
      final games = await state.getDataService().getPlayedGames(userId: userId);

      // Assert
      expect(games.isNotEmpty, true);
      expect(games.length, 1);
      expect(games[0]['gameId'], gameId);
      expect(games[0]['gameTitle'], 'Game 1');
      verify(mockUserCacheService.getCachedGamesPlayed()).called(1);
      verify(mockGameCacheService.getCachedGameData(gameId)).called(1);
      verifyNoMoreInteractions(mockUserCacheService);
      verifyNoMoreInteractions(mockGameCacheService);
    });

    testWidgets('should load games from Firestore when cache is empty', (WidgetTester tester) async {
      // Arrange: Simulate no cached games
      when(mockUserCacheService.getCachedGamesPlayed()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));

      // Act
      final games = await state.getDataService().getPlayedGames(userId: userId);

      // Assert
      expect(games.isNotEmpty, true);
      expect(games[0]['gameId'], gameId);
      verify(mockUserCacheService.getCachedGamesPlayed()).called(1);
      verify(mockFirestoreService.getPlayedGames(uid: userId)).called(1);
      verifyNoMoreInteractions(mockUserCacheService);
      verifyNoMoreInteractions(mockFirestoreService);
    });

    testWidgets('should return an empty list if an error occurs', (WidgetTester tester) async {
      // Arrange: Simulate an error while getting data
      when(mockUserCacheService.getCachedGamesPlayed()).thenThrow(Exception('Cache error'));

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));

      // Act
      final games = await state.getDataService().getPlayedGames(userId: userId);

      // Assert
      expect(games.isEmpty, true);
      verify(mockUserCacheService.getCachedGamesPlayed()).called(1);
      verifyNoMoreInteractions(mockUserCacheService);
    });
  });

  group('getSubjectData', () {
    const subjectId = 'subject123';

    setUp(() {
      // Reset mocks for each test
      when(mockSubjectCacheService.getCachedSubjectData(subjectId)).thenAnswer((_) async => SubjectData(
        subjectId: subjectId,
        subjectName: 'Mathematics',
        subjectLogo: '',
        teacher: '',
        students: [],
        assignments: [],
      ));

      when(mockFirestoreService.fetchSubjectData(subjectId: subjectId)).thenAnswer((_) async => SubjectData(
        subjectId: subjectId,
        subjectName: 'Mathematics',
        subjectLogo: '',
        teacher: '',
        students: [],
        assignments: [],
      ));

      when(mockSubjectCacheService.cacheSubjectData(any)).thenAnswer((_) async {});
    });

    testWidgets('should load subject data from cache', (WidgetTester tester) async {
      // Arrange: Mock the cache with subject data
      when(mockSubjectCacheService.getCachedSubjectData(subjectId))
          .thenAnswer((_) async => SubjectData(subjectName: 'Mathematics', subjectId: subjectId, subjectLogo: '', teacher: '', students: [], assignments: []));

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));

      // Act
      final subject = await state.getDataService().getSubjectData(subjectId: subjectId);

      // Assert
      expect(subject, isNotNull);
      expect(subject?.subjectId, subjectId);
      expect(subject?.subjectName, 'Mathematics');
      verify(mockSubjectCacheService.getCachedSubjectData(subjectId)).called(1);
      verifyNoMoreInteractions(mockSubjectCacheService);
      verifyNoMoreInteractions(mockFirestoreService);
    });

    testWidgets('should load subject data from Firestore when cache is empty', (WidgetTester tester) async {
      // Arrange: Simulate no cached subject data
      when(mockSubjectCacheService.getCachedSubjectData(subjectId))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));

      // Act
      final subject = await state.getDataService().getSubjectData(subjectId: subjectId);

      // Assert
      expect(subject, isNotNull);
      expect(subject?.subjectId, subjectId);
      expect(subject?.subjectName, 'Mathematics');
      verify(mockSubjectCacheService.getCachedSubjectData(subjectId)).called(1);
      verify(mockFirestoreService.fetchSubjectData(subjectId: subjectId)).called(1);
      verify(mockSubjectCacheService.cacheSubjectData(any)).called(1);
      verifyNoMoreInteractions(mockSubjectCacheService);
      verifyNoMoreInteractions(mockFirestoreService);
    });

    testWidgets('should return null if an error occurs', (WidgetTester tester) async {
      // Arrange: Simulate an error when fetching subject data
      when(mockSubjectCacheService.getCachedSubjectData(subjectId))
          .thenThrow(Exception('Cache error'));

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));

      // Act
      final subject = await state.getDataService().getSubjectData(subjectId: subjectId);

      // Assert
      expect(subject, isNull);
      verify(mockSubjectCacheService.getCachedSubjectData(subjectId)).called(1);
      verifyNoMoreInteractions(mockSubjectCacheService);
      verifyNoMoreInteractions(mockFirestoreService);
    });
  });

  group('checkIfStudentAlreadyInClass', () {
    const subjectId = 'subject123';
    const studentId = 'student123';

    setUp(() {
      // Initialize mocks before each test
      when(mockFirestoreService.checkIfStudentAlreadyInClass(subjectId: subjectId, studentId: studentId))
          .thenAnswer((_) async => true);
    });

    testWidgets('should return true if student is already in the class', (WidgetTester tester) async {
      // Arrange: Mock the Firestore service to return true (student is in class)
      when(mockFirestoreService.checkIfStudentAlreadyInClass(subjectId: subjectId, studentId: studentId))
          .thenAnswer((_) async => true);

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));

      // Act
      final isStudentInClass = await state.getDataService().checkIfStudentAlreadyInClass(subjectId: subjectId, studentId: studentId);

      // Assert
      expect(isStudentInClass, true);
      verify(mockFirestoreService.checkIfStudentAlreadyInClass(subjectId: subjectId, studentId: studentId)).called(1);
      verifyNoMoreInteractions(mockFirestoreService);
    });

    testWidgets('should return false if student is not in the class', (WidgetTester tester) async {
      // Arrange: Mock the Firestore service to return false (student is not in class)
      when(mockFirestoreService.checkIfStudentAlreadyInClass(subjectId: subjectId, studentId: studentId))
          .thenAnswer((_) async => false);

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));

      // Act
      final isStudentInClass = await state.getDataService().checkIfStudentAlreadyInClass(subjectId: subjectId, studentId: studentId);

      // Assert
      expect(isStudentInClass, false);
      verify(mockFirestoreService.checkIfStudentAlreadyInClass(subjectId: subjectId, studentId: studentId)).called(1);
      verifyNoMoreInteractions(mockFirestoreService);
    });

    testWidgets('should throw an exception if Firestore call fails', (WidgetTester tester) async {
      // Arrange: Simulate an error in Firestore service
      when(mockFirestoreService.checkIfStudentAlreadyInClass(subjectId: subjectId, studentId: studentId))
          .thenThrow(Exception('Error checking student class enrollment'));

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));

      // Act & Assert
      expect(
            () async => await state.getDataService().checkIfStudentAlreadyInClass(subjectId: subjectId, studentId: studentId),
        throwsA(isA<Exception>()), // Expect an exception to be thrown
      );

      verify(mockFirestoreService.checkIfStudentAlreadyInClass(subjectId: subjectId, studentId: studentId)).called(1);
      verifyNoMoreInteractions(mockFirestoreService);
    });
  });

  group('getAllSubjects', () {
    final uid = '12345';
    final mockUserData = UserData(
      id: '12345',
      username: 'testuser',
      email: 'test@example.com',
      name: 'Test User',
      role: 'student',
      birthdate: DateTime(2000, 1, 1),
      gamesPlayed: [],
      myGames: [],
      tClasses: [],
      stClasses: ['subject1', 'subject2'],
      img: 'testimage.png',
    );

    testWidgets('should load subjects from cache when available', (WidgetTester tester) async {
      // Arrange: Mock user data and cached subjects
      when(mockUserCacheService.getCachedUserData()).thenAnswer((_) async => mockUserData);
      when(mockSubjectCacheService.getCachedSubjectData('subject1')).thenAnswer((_) async => SubjectData(
        subjectId: 'subject1',
        subjectName: 'Subject 1',
        subjectLogo: 'logo1.png',
        teacher: '',
        students: [],
        assignments: [],
      ));
      when(mockSubjectCacheService.getCachedSubjectData('subject2')).thenAnswer((_) async => SubjectData(
        subjectId: 'subject2',
        subjectName: 'Subject 2',
        subjectLogo: 'logo2.png',
        teacher: '',
        students: [],
        assignments: [],
      ));

      // Act: Call getAllSubjects
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      final result = await state.getDataService().getAllSubjects(uid: uid);

      // Assert: Verify subjects are loaded from cache
      expect(result, isNotEmpty);
      expect(result[0]['subjectId'], 'subject1');
      expect(result[1]['subjectId'], 'subject2');
      verify(mockSubjectCacheService.getCachedSubjectData('subject1')).called(1);
      verify(mockSubjectCacheService.getCachedSubjectData('subject2')).called(1);
    });

    testWidgets('should load subjects from Firestore when not in cache', (WidgetTester tester) async {
      // Arrange: Mock user data and cache miss
      when(mockUserCacheService.getCachedUserData()).thenAnswer((_) async => mockUserData);
      when(mockSubjectCacheService.getCachedSubjectData('subject1')).thenAnswer((_) async => null);
      when(mockSubjectCacheService.getCachedSubjectData('subject2')).thenAnswer((_) async => null);

      when(mockFirestoreService.fetchSubjectData(subjectId: 'subject1')).thenAnswer((_) async => SubjectData(
        subjectId: 'subject1',
        subjectName: 'Subject 1',
        subjectLogo: 'logo1.png', teacher: '',
        students: [],
        assignments: [],
      ));
      when(mockFirestoreService.fetchSubjectData(subjectId: 'subject2')).thenAnswer((_) async => SubjectData(
        subjectId: 'subject2',
        subjectName: 'Subject 2',
        subjectLogo: 'logo2.png',
        teacher: '',
        students: [],
        assignments: [],
      ));

      // Act: Call getAllSubjects
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      final result = await state.getDataService().getAllSubjects(uid: uid);

      // Assert: Verify subjects are fetched from Firestore
      expect(result, isNotEmpty);
      expect(result[0]['subjectId'], 'subject1');
      expect(result[1]['subjectId'], 'subject2');
      verify(mockFirestoreService.fetchSubjectData(subjectId: 'subject1')).called(1);
      verify(mockFirestoreService.fetchSubjectData(subjectId: 'subject2')).called(1);
    });

    testWidgets('should return an empty list if user data is null', (WidgetTester tester) async {
      // Arrange: Mock that user data is null
      when(mockUserCacheService.getCachedUserData()).thenAnswer((_) async => null);

      // Act: Call getAllSubjects
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      final result = await state.getDataService().getAllSubjects(uid: uid);

      // Assert: Verify that an empty list is returned
      expect(result, isEmpty);
    });

    testWidgets('should return an empty list if an error occurs', (WidgetTester tester) async {
      // Arrange: Mock user data and simulate an error
      when(mockUserCacheService.getCachedUserData()).thenAnswer((_) async => mockUserData);
      when(mockSubjectCacheService.getCachedSubjectData('subject1')).thenAnswer((_) async => null);
      when(mockSubjectCacheService.getCachedSubjectData('subject2')).thenAnswer((_) async => null);
      when(mockFirestoreService.fetchSubjectData(subjectId: 'subject1')).thenThrow(Exception('Error fetching subject'));

      // Act: Call getAllSubjects
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      final result = await state.getDataService().getAllSubjects(uid: uid);

      // Assert: Verify that an empty list is returned
      expect(result, isEmpty);
    });
  });

  group('addSubject', () {
    testWidgets('should successfully add subject to Firestore and update cache', (WidgetTester tester) async {
      // Arrange: Mock services to return successful values
      final mockSubject = SubjectData(
        subjectId: 'subject1',
        subjectName: 'Subject 1',
        subjectLogo: 'subject_logo.png',
        teacher: '',
        students: [],
        assignments: [],
      );

      final mockUserData = UserData(
        id: 'user1',
        username: 'username',
        email: 'user@example.com',
        name: 'User Name',
        role: 'student',
        birthdate: DateTime.now(),
        gamesPlayed: [],
        myGames: [],
        stClasses: [],
        tClasses: ['subject2'],
        img: 'image.png',
      );

      // Mock Firestore and Cache behavior
      when(mockFirestoreService.addSubjectData(subject: mockSubject, uid: 'user1'))
          .thenAnswer((_) async {});
      when(mockSubjectCacheService.cacheSubjectData(mockSubject))
          .thenAnswer((_) async {});
      when(mockUserCacheService.getCachedUserData())
          .thenAnswer((_) async => mockUserData);

      // Act: Call the function to add a subject
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      await state.getDataService().addSubject(subject: mockSubject, uid: 'user1');

      // Assert: Verify Firestore and Cache interactions
      verify(mockFirestoreService.addSubjectData(subject: mockSubject, uid: 'user1')).called(1);
      verify(mockSubjectCacheService.cacheSubjectData(mockSubject)).called(1);
      verify(mockUserCacheService.getCachedUserData()).called(1);
      verify(mockUserCacheService.clearUserCache()).called(1);
      verify(mockUserCacheService.cacheUserData(mockUserData)).called(1);
    });

    testWidgets('should throw exception if Firestore fails to add subject', (WidgetTester tester) async {
      // Arrange: Mock Firestore to throw an exception
      final mockSubject = SubjectData(
        subjectId: 'subject1',
        subjectName: 'Subject 1',
        subjectLogo: 'subject_logo.png',
        teacher: '',
        students: [],
        assignments: [],
      );

      when(mockFirestoreService.addSubjectData(subject: mockSubject, uid: 'user1'))
          .thenThrow(Exception('Firestore error'));

      // Act & Assert: Call the function and expect an exception to be thrown
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      expect(
            () => state.getDataService().addSubject(subject: mockSubject, uid: 'user1'),
        throwsA(isA<Exception>()),
      );

      verify(mockFirestoreService.addSubjectData(subject: mockSubject, uid: 'user1')).called(1);
      verifyNoMoreInteractions(mockSubjectCacheService);
      verifyNoMoreInteractions(mockUserCacheService);
    });

    testWidgets('should throw exception if caching subject fails', (WidgetTester tester) async {
      // Arrange: Mock successful Firestore call but cache fails
      final mockSubject = SubjectData(
        subjectId: 'subject1',
        subjectName: 'Subject 1',
        subjectLogo: 'subject_logo.png',
        teacher: '',
        students: [],
        assignments: [],
      );

      when(mockFirestoreService.addSubjectData(subject: mockSubject, uid: 'user1'))
          .thenAnswer((_) async {});
      when(mockSubjectCacheService.cacheSubjectData(mockSubject))
          .thenThrow(Exception('Cache error'));

      // Act & Assert: Call the function and expect an exception to be thrown
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      expect(
            () => state.getDataService().addSubject(subject: mockSubject, uid: 'user1'),
        throwsA(isA<Exception>()),
      );

      await tester.pump();

      verify(mockFirestoreService.addSubjectData(subject: mockSubject, uid: 'user1')).called(1);
      verify(mockSubjectCacheService.cacheSubjectData(mockSubject)).called(1);
      verifyNoMoreInteractions(mockUserCacheService);
    });

    testWidgets('should throw exception if user data fetching fails', (WidgetTester tester) async {
      // Arrange: Mock Firestore and Cache calls
      final mockSubject = SubjectData(
        subjectId: 'subject1',
        subjectName: 'Subject 1',
        subjectLogo: 'subject_logo.png',
        teacher: '',
        students: [],
        assignments: [],
      );

      when(mockFirestoreService.addSubjectData(subject: mockSubject, uid: 'user1'))
          .thenAnswer((_) async {});
      when(mockSubjectCacheService.cacheSubjectData(mockSubject))
          .thenAnswer((_) async {});
      when(mockUserCacheService.getCachedUserData())
          .thenAnswer((_) async => null); // Simulate user data fetch failure
      when(mockFirestoreService.fetchUserData(userId: 'user1'))
          .thenThrow(Exception('Failed to fetch user data'));

      // Act & Assert: Call the function and expect an exception to be thrown
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      expect(
            () => state.getDataService().addSubject(subject: mockSubject, uid: 'user1'),
        throwsA(isA<Exception>()),
      );

      await tester.pump();

      verify(mockFirestoreService.addSubjectData(subject: mockSubject, uid: 'user1')).called(1);
      verify(mockSubjectCacheService.cacheSubjectData(mockSubject)).called(1);
      verify(mockUserCacheService.getCachedUserData()).called(1);
      verify(mockFirestoreService.fetchUserData(userId: 'user1')).called(1);
    });
  });

  group('deleteSubject', () {
    testWidgets('should successfully delete a subject from Firestore, cache, and update user data', (WidgetTester tester) async {
      // Arrange: Mock services to simulate success
      final mockSubjectId = 'subject1';
      final mockUid = 'user1';

      final mockUserData = UserData(
        id: 'user1',
        username: 'username',
        email: 'user@example.com',
        name: 'User Name',
        role: 'student',
        birthdate: DateTime.now(),
        gamesPlayed: [],
        myGames: [],
        stClasses: [],
        tClasses: ['subject1', 'subject2'],
        img: 'image.png',
      );

      // Mock service calls
      when(mockFirestoreService.deleteSubject(subjectId: mockSubjectId, uid: mockUid))
          .thenAnswer((_) async {});
      when(mockSubjectCacheService.deleteSubject(subjectId: mockSubjectId))
          .thenAnswer((_) async {});
      when(mockUserCacheService.getCachedUserData())
          .thenAnswer((_) async => mockUserData);
      when(mockUserCacheService.clearUserCache())
          .thenAnswer((_) async {});
      when(mockUserCacheService.cacheUserData(mockUserData))
          .thenAnswer((_) async {});

      // Act: Call the deleteSubject method
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      await state.getDataService().deleteSubject(subjectId: mockSubjectId, uid: mockUid);

      // Assert: Verify that Firestore, cache, and user data are correctly updated
      verify(mockFirestoreService.deleteSubject(subjectId: mockSubjectId, uid: mockUid)).called(1);
      verify(mockSubjectCacheService.deleteSubject(subjectId: mockSubjectId)).called(1);
      verify(mockUserCacheService.getCachedUserData()).called(1);
      verify(mockUserCacheService.clearUserCache()).called(1);
      verify(mockUserCacheService.cacheUserData(mockUserData)).called(1);
    });

    testWidgets('should throw exception if Firestore fails to delete the subject', (WidgetTester tester) async {
      // Arrange: Mock Firestore to throw an error
      final mockSubjectId = 'subject1';
      final mockUid = 'user1';

      when(mockFirestoreService.deleteSubject(subjectId: mockSubjectId, uid: mockUid))
          .thenThrow(Exception('Firestore error'));

      // Act & Assert: Call the method and expect an exception to be thrown
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      expect(
            () => state.getDataService().deleteSubject(subjectId: mockSubjectId, uid: mockUid),
        throwsA(isA<Exception>()),
      );

      verify(mockFirestoreService.deleteSubject(subjectId: mockSubjectId, uid: mockUid)).called(1);
      verifyNoMoreInteractions(mockSubjectCacheService);
      verifyNoMoreInteractions(mockUserCacheService);
    });

    testWidgets('should throw exception if cache deletion fails', (WidgetTester tester) async {
      // Arrange: Mock Firestore and simulate cache failure
      final mockSubjectId = 'subject1';
      final mockUid = 'user1';

      when(mockFirestoreService.deleteSubject(subjectId: mockSubjectId, uid: mockUid))
          .thenAnswer((_) async {});
      when(mockSubjectCacheService.deleteSubject(subjectId: mockSubjectId))
          .thenThrow(Exception('Cache error'));

      // Act & Assert: Call the method and expect an exception to be thrown
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      expect(
            () => state.getDataService().deleteSubject(subjectId: mockSubjectId, uid: mockUid),
        throwsA(isA<Exception>()),
      );

      await tester.pump();

      verify(mockFirestoreService.deleteSubject(subjectId: mockSubjectId, uid: mockUid)).called(1);
      verify(mockSubjectCacheService.deleteSubject(subjectId: mockSubjectId)).called(1);
      verifyNoMoreInteractions(mockUserCacheService);
    });

    testWidgets('should throw exception if user data fetching fails', (WidgetTester tester) async {
      // Arrange: Mock successful deletion, but simulate failure in fetching user data
      final mockSubjectId = 'subject1';
      final mockUid = 'user1';

      when(mockFirestoreService.deleteSubject(subjectId: mockSubjectId, uid: mockUid))
          .thenAnswer((_) async {});
      when(mockSubjectCacheService.deleteSubject(subjectId: mockSubjectId))
          .thenAnswer((_) async {});
      when(mockUserCacheService.getCachedUserData())
          .thenAnswer((_) async => null); // Simulate user data fetch failure
      when(mockFirestoreService.fetchUserData(userId: mockUid))
          .thenThrow(Exception('Failed to fetch user data'));

      // Act & Assert: Call the method and expect an exception to be thrown
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      expect(
            () => state.getDataService().deleteSubject(subjectId: mockSubjectId, uid: mockUid),
        throwsA(isA<Exception>()),
      );

      await tester.pump();

      verify(mockFirestoreService.deleteSubject(subjectId: mockSubjectId, uid: mockUid)).called(1);
      verify(mockSubjectCacheService.deleteSubject(subjectId: mockSubjectId)).called(1);
      verify(mockUserCacheService.getCachedUserData()).called(1);
      verify(mockFirestoreService.fetchUserData(userId: mockUid)).called(1);
    });
  });

  group('addStudentToSubject', () {
    testWidgets('should successfully add student to subject, update Firestore, and cache', (WidgetTester tester) async {
      // Arrange: Mock services to simulate successful data flow
      final mockSubjectId = 'subject1';
      final mockStudentId = 'student1';
      final updatedSubject = SubjectData(
        subjectId: mockSubjectId,
        subjectName: 'Subject Name',
        subjectLogo: 'subject_logo.png',
        teacher: '',
        students: [],
        assignments: []
      );

      // Mock service calls
      when(mockFirestoreService.addStudentToSubject(subjectId: mockSubjectId, studentId: mockStudentId))
          .thenAnswer((_) async {});
      when(mockFirestoreService.fetchSubjectData(subjectId: mockSubjectId))
          .thenAnswer((_) async => updatedSubject);
      when(mockSubjectCacheService.deleteSubject(subjectId: mockSubjectId))
          .thenAnswer((_) async {});
      when(mockSubjectCacheService.cacheSubjectData(updatedSubject))
          .thenAnswer((_) async {});

      // Act: Call the addStudentToSubject method
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      await state.getDataService().addStudentToSubject(subjectId: mockSubjectId, studentId: mockStudentId);

      // Assert: Verify that Firestore and cache interactions occur as expected
      verify(mockFirestoreService.addStudentToSubject(subjectId: mockSubjectId, studentId: mockStudentId)).called(1);
      verify(mockFirestoreService.fetchSubjectData(subjectId: mockSubjectId)).called(1);
      verify(mockSubjectCacheService.deleteSubject(subjectId: mockSubjectId)).called(1);
      verify(mockSubjectCacheService.cacheSubjectData(updatedSubject)).called(1);
    });

    testWidgets('should throw exception if Firestore fails to add student to subject', (WidgetTester tester) async {
      // Arrange: Mock Firestore to throw an error
      final mockSubjectId = 'subject1';
      final mockStudentId = 'student1';

      when(mockFirestoreService.addStudentToSubject(subjectId: mockSubjectId, studentId: mockStudentId))
          .thenThrow(Exception('Error adding student to subject'));

      // Act & Assert: Call the method and expect an exception to be thrown
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      expect(
            () => state.getDataService().addStudentToSubject(subjectId: mockSubjectId, studentId: mockStudentId),
        throwsA(isA<Exception>()),
      );

      await tester.pump();

      verify(mockFirestoreService.addStudentToSubject(subjectId: mockSubjectId, studentId: mockStudentId)).called(1);
      verifyNoMoreInteractions(mockFirestoreService);
      verifyNoMoreInteractions(mockSubjectCacheService);
    });

    testWidgets('should throw exception if fetching updated subject data fails', (WidgetTester tester) async {
      // Arrange: Mock Firestore and simulate error in fetching updated subject data
      final mockSubjectId = 'subject1';
      final mockStudentId = 'student1';

      when(mockFirestoreService.addStudentToSubject(subjectId: mockSubjectId, studentId: mockStudentId))
          .thenAnswer((_) async {});
      when(mockFirestoreService.fetchSubjectData(subjectId: mockSubjectId))
          .thenThrow(Exception('Error fetching updated subject data'));

      // Act & Assert: Call the method and expect an exception to be thrown
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      expect(
            () => state.getDataService().addStudentToSubject(subjectId: mockSubjectId, studentId: mockStudentId),
        throwsA(isA<Exception>()),
      );

      await tester.pump();

      verify(mockFirestoreService.addStudentToSubject(subjectId: mockSubjectId, studentId: mockStudentId)).called(1);
      verify(mockFirestoreService.fetchSubjectData(subjectId: mockSubjectId)).called(1);
      verifyNoMoreInteractions(mockSubjectCacheService);
    });

    testWidgets('should throw exception if cache deletion or caching fails', (WidgetTester tester) async {
      // Arrange: Mock Firestore and simulate error in cache operations
      final mockSubjectId = 'subject1';
      final mockStudentId = 'student1';
      final updatedSubject = SubjectData(
        subjectId: mockSubjectId,
        subjectName: 'Subject Name',
        subjectLogo: 'subject_logo.png',
        teacher: '',
        students: [],
        assignments: [],
      );

      when(mockFirestoreService.addStudentToSubject(subjectId: mockSubjectId, studentId: mockStudentId))
          .thenAnswer((_) async {});
      when(mockFirestoreService.fetchSubjectData(subjectId: mockSubjectId))
          .thenAnswer((_) async => updatedSubject);
      when(mockSubjectCacheService.deleteSubject(subjectId: mockSubjectId))
          .thenAnswer((_) async {});
      when(mockSubjectCacheService.cacheSubjectData(updatedSubject))
          .thenThrow(Exception('Cache error'));

      // Act & Assert: Call the method and expect an exception to be thrown
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      expect(
            () => state.getDataService().addStudentToSubject(subjectId: mockSubjectId, studentId: mockStudentId),
        throwsA(isA<Exception>()),
      );

      await tester.pump();

      verify(mockFirestoreService.addStudentToSubject(subjectId: mockSubjectId, studentId: mockStudentId)).called(1);
      verify(mockFirestoreService.fetchSubjectData(subjectId: mockSubjectId)).called(1);
      verify(mockSubjectCacheService.deleteSubject(subjectId: mockSubjectId)).called(1);
      verify(mockSubjectCacheService.cacheSubjectData(updatedSubject)).called(1);
    });
  });

  group('removeStudentFromSubject', () {
    testWidgets('should successfully remove student from subject, update Firestore, and cache', (WidgetTester tester) async {
      // Arrange: Mock services to simulate successful data flow
      final mockSubjectId = 'subject1';
      final mockStudentId = 'student1';
      final updatedSubject = SubjectData(
        subjectId: mockSubjectId,
        subjectName: 'Subject Name',
        subjectLogo: 'subject_logo.png',
        teacher: '',
        students: [],
        assignments: [],
      );

      // Mock service calls
      when(mockFirestoreService.removeStudentFromSubject(subjectId: mockSubjectId, studentId: mockStudentId))
          .thenAnswer((_) async {});
      when(mockFirestoreService.fetchSubjectData(subjectId: mockSubjectId))
          .thenAnswer((_) async => updatedSubject);
      when(mockSubjectCacheService.deleteSubject(subjectId: mockSubjectId))
          .thenAnswer((_) async {});
      when(mockSubjectCacheService.cacheSubjectData(updatedSubject))
          .thenAnswer((_) async {});

      // Act: Call the removeStudentFromSubject method
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      await state.getDataService().removeStudentFromSubject(subjectId: mockSubjectId, studentId: mockStudentId);

      // Assert: Verify that Firestore and cache interactions occur as expected
      verify(mockFirestoreService.removeStudentFromSubject(subjectId: mockSubjectId, studentId: mockStudentId)).called(1);
      verify(mockFirestoreService.fetchSubjectData(subjectId: mockSubjectId)).called(1);
      verify(mockSubjectCacheService.deleteSubject(subjectId: mockSubjectId)).called(1);
      verify(mockSubjectCacheService.cacheSubjectData(updatedSubject)).called(1);
    });

    testWidgets('should throw exception if Firestore fails to remove student from subject', (WidgetTester tester) async {
      // Arrange: Mock Firestore to throw an error
      final mockSubjectId = 'subject1';
      final mockStudentId = 'student1';

      when(mockFirestoreService.removeStudentFromSubject(subjectId: mockSubjectId, studentId: mockStudentId))
          .thenThrow(Exception('Error removing student from subject'));

      // Act & Assert: Call the method and expect an exception to be thrown
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      expect(
            () async => await state.getDataService().removeStudentFromSubject(subjectId: mockSubjectId, studentId: mockStudentId),
        throwsA(isA<Exception>()),
      );

      verify(mockFirestoreService.removeStudentFromSubject(subjectId: mockSubjectId, studentId: mockStudentId)).called(1);
      verifyNoMoreInteractions(mockFirestoreService);
      verifyNoMoreInteractions(mockSubjectCacheService);
    });

    testWidgets('should throw exception if fetching updated subject data fails', (WidgetTester tester) async {
      // Arrange: Mock Firestore and simulate error in fetching updated subject data
      final mockSubjectId = 'subject1';
      final mockStudentId = 'student1';

      // Mock the behavior for removing the student from the subject and fetching subject data
      when(mockFirestoreService.removeStudentFromSubject(subjectId: mockSubjectId, studentId: mockStudentId))
          .thenAnswer((_) async {});
      when(mockFirestoreService.fetchSubjectData(subjectId: mockSubjectId))
          .thenThrow(Exception('Error fetching updated subject data'));

      // Act: Initialize the widget and call the method
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));

      // Assert: Ensure that an exception is thrown when the method is called
      expect(
            () async => await state.getDataService().removeStudentFromSubject(subjectId: mockSubjectId, studentId: mockStudentId),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Error removing student from subject'))),
      );

      await tester.pump();

      // Ensure expected interactions with Firestore
      verify(mockFirestoreService.removeStudentFromSubject(subjectId: mockSubjectId, studentId: mockStudentId)).called(1);
      verify(mockFirestoreService.fetchSubjectData(subjectId: mockSubjectId)).called(1);
      verify(mockSubjectCacheService.deleteSubject(subjectId: mockSubjectId)).called(1);

      // Ensure no unexpected interactions with the cache service (deleteSubject shouldn't be called)
      verifyNoMoreInteractions(mockSubjectCacheService);
    });

    testWidgets('should throw exception if cache deletion or caching fails', (WidgetTester tester) async {
      // Arrange: Mock Firestore and simulate error in cache operations
      final mockSubjectId = 'subject1';
      final mockStudentId = 'student1';
      final updatedSubject = SubjectData(
        subjectId: mockSubjectId,
        subjectName: 'Subject Name',
        subjectLogo: 'subject_logo.png',
        teacher: '',
        students: [],
        assignments: [],
      );

      when(mockFirestoreService.removeStudentFromSubject(subjectId: mockSubjectId, studentId: mockStudentId))
          .thenAnswer((_) async {});
      when(mockFirestoreService.fetchSubjectData(subjectId: mockSubjectId))
          .thenAnswer((_) async => updatedSubject);
      when(mockSubjectCacheService.deleteSubject(subjectId: mockSubjectId))
          .thenAnswer((_) async {});
      when(mockSubjectCacheService.cacheSubjectData(updatedSubject))
          .thenThrow(Exception('Cache error'));

      // Act & Assert: Call the method and expect an exception to be thrown
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      expect(
            () => state.getDataService().removeStudentFromSubject(subjectId: mockSubjectId, studentId: mockStudentId),
        throwsA(isA<Exception>()),
      );

      await tester.pump();

      verify(mockFirestoreService.removeStudentFromSubject(subjectId: mockSubjectId, studentId: mockStudentId)).called(1);
      verify(mockFirestoreService.fetchSubjectData(subjectId: mockSubjectId)).called(1);
      verify(mockSubjectCacheService.deleteSubject(subjectId: mockSubjectId)).called(1);
      verify(mockSubjectCacheService.cacheSubjectData(updatedSubject)).called(1);
    });
  });

  group('createAssignment', () {
    testWidgets('should successfully create assignment and update cache', (WidgetTester tester) async {
      // Arrange: Mock services to simulate successful assignment creation
      final mockTitle = 'New Assignment';
      final mockDueDate = DateTime(2025, 6, 1);
      final mockTurma = 'subject1';
      final mockGameId = 'game1';
      final mockAssId = 'assignment1';
      final mockSubjectData = SubjectData(
        subjectId: mockTurma,
        subjectName: 'Subject Name',
        subjectLogo: 'subject_logo.png',
        assignments: [],
        teacher: '',
        students: [],
      );

      // Mock service calls
      when(mockFirestoreService.createAssignment(
        title: mockTitle,
        dueDate: mockDueDate.toString(),
        turma: mockTurma,
        gameId: mockGameId,
      )).thenAnswer((_) async => mockAssId);

      when(mockSubjectCacheService.getCachedSubjectData(mockTurma))
          .thenAnswer((_) async => mockSubjectData);
      when(mockSubjectCacheService.deleteSubject(subjectId: mockTurma))
          .thenAnswer((_) async {});
      when(mockSubjectCacheService.cacheSubjectData(mockSubjectData))
          .thenAnswer((_) async {});

      // Act: Call the createAssignment method
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      await state.getDataService().createAssignment(
        title: mockTitle,
        dueDate: mockDueDate,
        turma: mockTurma,
        gameId: mockGameId,
      );

      // Assert: Verify that Firestore and cache interactions occur as expected
      verify(mockFirestoreService.createAssignment(
        title: mockTitle,
        dueDate: mockDueDate.toString(),
        turma: mockTurma,
        gameId: mockGameId,
      )).called(1);
      verify(mockSubjectCacheService.getCachedSubjectData(mockTurma)).called(1);
      verify(mockSubjectCacheService.deleteSubject(subjectId: mockTurma)).called(1);
      verify(mockSubjectCacheService.cacheSubjectData(mockSubjectData)).called(1);
    });

    testWidgets('should throw exception if Firestore assignment creation fails', (WidgetTester tester) async {
      // Arrange: Mock Firestore to throw an error while creating the assignment
      final mockTitle = 'New Assignment';
      final mockDueDate = DateTime(2025, 6, 1);
      final mockTurma = 'subject1';
      final mockGameId = 'game1';

      when(mockFirestoreService.createAssignment(
        title: mockTitle,
        dueDate: mockDueDate.toString(),
        turma: mockTurma,
        gameId: mockGameId,
      )).thenThrow(Exception('Error creating assignment'));

      // Act & Assert: Call the method and expect an exception to be thrown
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      expect(
            () => state.getDataService().createAssignment(
          title: mockTitle,
          dueDate: mockDueDate,
          turma: mockTurma,
          gameId: mockGameId,
        ),
        throwsA(isA<Exception>()),
      );

      await tester.pump();

      verify(mockFirestoreService.createAssignment(
        title: mockTitle,
        dueDate: mockDueDate.toString(),
        turma: mockTurma,
        gameId: mockGameId,
      )).called(1);
      verifyNoMoreInteractions(mockSubjectCacheService);
    });

    testWidgets('should handle failure when fetching subject data from Firestore', (WidgetTester tester) async {
      // Arrange: Mock Firestore to throw an error when fetching subject data
      final mockTitle = 'New Assignment';
      final mockDueDate = DateTime(2025, 6, 1);
      final mockTurma = 'subject1';
      final mockGameId = 'game1';
      final mockAssId = 'assignment1';

      when(mockFirestoreService.createAssignment(
        title: mockTitle,
        dueDate: mockDueDate.toString(),
        turma: mockTurma,
        gameId: mockGameId,
      )).thenAnswer((_) async => mockAssId);

      when(mockSubjectCacheService.getCachedSubjectData(mockTurma))
          .thenAnswer((_) async => null); // Simulating a missing cached subject
      when(mockFirestoreService.fetchSubjectData(subjectId: mockTurma))
          .thenThrow(Exception('Error fetching subject data'));

      // Act & Assert: Call the method and expect an exception to be thrown
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      expect(
            () => state.getDataService().createAssignment(
          title: mockTitle,
          dueDate: mockDueDate,
          turma: mockTurma,
          gameId: mockGameId,
        ),
        throwsA(isA<Exception>()),
      );

      await tester.pump();

      verify(mockFirestoreService.createAssignment(
        title: mockTitle,
        dueDate: mockDueDate.toString(),
        turma: mockTurma,
        gameId: mockGameId,
      )).called(1);
      verify(mockSubjectCacheService.getCachedSubjectData(mockTurma)).called(1);
      verify(mockFirestoreService.fetchSubjectData(subjectId: mockTurma)).called(1);
      verifyNoMoreInteractions(mockSubjectCacheService);
    });

    testWidgets('should handle failure when cache update fails', (WidgetTester tester) async {
      // Arrange: Mock Firestore and simulate failure during cache update
      final mockTitle = 'New Assignment';
      final mockDueDate = DateTime(2025, 6, 1);
      final mockTurma = 'subject1';
      final mockGameId = 'game1';
      final mockAssId = 'assignment1';
      final mockSubjectData = SubjectData(
        subjectId: mockTurma,
        subjectName: 'Subject Name',
        subjectLogo: 'subject_logo.png',
        assignments: [],
        teacher: '',
        students: [],
      );

      when(mockFirestoreService.createAssignment(
        title: mockTitle,
        dueDate: mockDueDate.toString(),
        turma: mockTurma,
        gameId: mockGameId,
      )).thenAnswer((_) async => mockAssId);

      when(mockSubjectCacheService.getCachedSubjectData(mockTurma))
          .thenAnswer((_) async => mockSubjectData);
      when(mockSubjectCacheService.deleteSubject(subjectId: mockTurma))
          .thenAnswer((_) async {});
      when(mockSubjectCacheService.cacheSubjectData(mockSubjectData))
          .thenThrow(Exception('Cache error'));

      // Act & Assert: Call the method and expect an exception to be thrown
      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      final state = tester.state<DataServiceTestWidgetState>(
        find.byType(DataServiceTestWidget),
      );
      expect(
            () => state.getDataService().createAssignment(
          title: mockTitle,
          dueDate: mockDueDate,
          turma: mockTurma,
          gameId: mockGameId,
        ),
        throwsA(isA<Exception>()),
      );

      await tester.pump();

      verify(mockFirestoreService.createAssignment(
        title: mockTitle,
        dueDate: mockDueDate.toString(),
        turma: mockTurma,
        gameId: mockGameId,
      )).called(1);
      verify(mockSubjectCacheService.getCachedSubjectData(mockTurma)).called(1);
      verify(mockSubjectCacheService.deleteSubject(subjectId: mockTurma)).called(1);
      verify(mockSubjectCacheService.cacheSubjectData(mockSubjectData)).called(1);
    });
  });

  group('getAllAssignments', () {
    testWidgets('should load assignments from cache when available', (WidgetTester tester) async {
      // Arrange
      final subjectId = 'subject1';
      final assignmentId = 'assignment1';
      final cachedAssignment = AssignmentData(
        assId: assignmentId,
        title: 'Assignment 1',
        subjectId: subjectId,
        dueDate: '2025-05-01',
        gameId: 'game1',
      );

      when(mockSubjectCacheService.getCachedSubjectData(subjectId))
          .thenAnswer((_) async => SubjectData(assignments: [assignmentId], subjectId: subjectId, subjectLogo: '', subjectName: '', teacher: '', students: []));
      when(mockAssignmentCacheService.getCachedAssignmentData(assignmentId))
          .thenAnswer((_) async => cachedAssignment);

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      // Act
      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));
      final result = await state.getDataService().getAllAssignments(subjectId: subjectId);

      // Assert
      expect(result, isNotEmpty);
      expect(result[0]['assignmentId'], assignmentId);
      expect(result[0]['title'], 'Assignment 1');
      verify(mockSubjectCacheService.getCachedSubjectData(subjectId)).called(1);
      verify(mockAssignmentCacheService.getCachedAssignmentData(assignmentId)).called(1);
    });

    testWidgets('should load assignments from Firestore when cache is empty', (WidgetTester tester) async {
      // Arrange
      final subjectId = 'subject1';
      final assignmentId = 'assignment1';
      final assignmentData = AssignmentData(
        assId: assignmentId,
        title: 'Assignment 1',
        subjectId: subjectId,
        dueDate: '2025-05-01',
        gameId: 'game1',
      );

      when(mockSubjectCacheService.getCachedSubjectData(subjectId))
          .thenAnswer((_) async => SubjectData(assignments: [assignmentId], subjectId: subjectId, subjectLogo: '', subjectName: '', teacher: '', students: []));
      when(mockAssignmentCacheService.getCachedAssignmentData(assignmentId))
          .thenAnswer((_) async => null); // Cache miss
      when(mockFirestoreService.fetchAssignmentData(assignmentId: assignmentId))
          .thenAnswer((_) async => assignmentData);

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      // Act
      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));
      final result = await state.getDataService().getAllAssignments(subjectId: subjectId);

      // Assert
      expect(result, isNotEmpty);
      expect(result[0]['assignmentId'], assignmentId);
      verify(mockSubjectCacheService.getCachedSubjectData(subjectId)).called(1);
      verify(mockAssignmentCacheService.getCachedAssignmentData(assignmentId)).called(1);
      verify(mockFirestoreService.fetchAssignmentData(assignmentId: assignmentId)).called(1);
    });

    testWidgets('should throw an exception if subject data is null', (WidgetTester tester) async {
      // Arrange
      final subjectId = 'subject1';

      when(mockSubjectCacheService.getCachedSubjectData(subjectId))
          .thenAnswer((_) async => null);
      when(mockFirestoreService.fetchSubjectData(subjectId: subjectId))
          .thenThrow(Exception('No Subject Data'));

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      // Act & Assert
      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));
      expect(
        await state.getDataService().getAllAssignments(subjectId: subjectId),
        [],
      );


      verify(mockSubjectCacheService.getCachedSubjectData(subjectId)).called(1);
    });

    testWidgets('should return empty list if an error occurs during assignment fetching', (WidgetTester tester) async {
      // Arrange
      final subjectId = 'subject1';

      when(mockSubjectCacheService.getCachedSubjectData(subjectId))
          .thenAnswer((_) async => SubjectData(assignments: ['assignment1'], subjectId: subjectId, subjectLogo: '', subjectName: '', teacher: '', students: []));
      when(mockAssignmentCacheService.getCachedAssignmentData('assignment1'))
          .thenAnswer((_) async => null); // Cache miss
      when(mockFirestoreService.fetchAssignmentData(assignmentId: 'assignment1'))
          .thenThrow(Exception('Error fetching assignment data'));

      await tester.pumpWidget(createTestableWidget(DataServiceTestWidget()));
      await tester.pumpAndSettle();

      // Act
      final state = tester.state<DataServiceTestWidgetState>(find.byType(DataServiceTestWidget));
      final result = await state.getDataService().getAllAssignments(subjectId: subjectId);

      // Assert
      expect(result, isEmpty);
      verify(mockSubjectCacheService.getCachedSubjectData(subjectId)).called(1);
      verify(mockAssignmentCacheService.getCachedAssignmentData('assignment1')).called(1);
      verify(mockFirestoreService.fetchAssignmentData(assignmentId: 'assignment1')).called(1);
    });
  });


}


class DataServiceTestWidget extends StatefulWidget {
  @override
  DataServiceTestWidgetState createState() => DataServiceTestWidgetState();
}

class DataServiceTestWidgetState extends State<DataServiceTestWidget> {
  late DataService dataService;

  @override
  void initState() {
    super.initState();
    dataService = DataService(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Service Setup Complete'),
      ),
    );
  }

  // Getter to expose the DataService instance
  DataService getDataService() {
    return dataService;
  }
}
