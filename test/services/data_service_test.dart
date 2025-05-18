import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/game_data.dart';
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
  MockSpec<BuildContext>(),
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
            () => state.getDataService().updateUserGamesPlayed(userId: userId, gameId: gameId),
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
            () => state.getDataService().deleteAccount(uid: uid),
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
            () => state.getDataService().createGame(uid: uid, game: gameData),
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
    // Initialize the DataService here within the widget context
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
