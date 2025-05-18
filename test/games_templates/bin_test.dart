import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/games_templates/results_page.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/services/firebase/auth_service.dart';
import 'package:mockito/mockito.dart';
import 'package:learnvironment/games_templates/bin.dart';
import 'package:fake_async/fake_async.dart';
import 'package:provider/provider.dart';

class MockAuthService extends Mock implements AuthService {
  late String uid;

  MockAuthService({MockFirebaseAuth? firebaseAuth}) {
    loggedIn = firebaseAuth?.currentUser != null;
    uid = firebaseAuth?.currentUser?.uid ?? '';
    fetchedNotifications = true;
  }

  @override
  Future<String> getUid() async {
    return uid;
  }

  @override
  Stream<User?> get authStateChanges => Stream.value(MockUser());
}

class MockDataService extends Mock implements DataService{
  @override
  Future<UserData?> getUserData({required String userId}) {
    return Future.value(UserData(role: '', id: '', username: '', name: '', email: '', birthdate: DateTime(2000, 1, 1, 0, 0, 0, 0, 0), gamesPlayed: [], myGames: [], tClasses: [], stClasses: [], img: ''));
  }
}

class MockGameData extends Mock implements GameData {
  @override
  String get gameLogo => 'assets/widget.png';

  @override
  String get gameName => 'Bin Game';

  @override
  String get gameDescription => 'Match the right piece of trash to the correct bin';

  @override
  String get gameBibliography => 'Bibliography';

  @override
  List<String> get tags => ['8+'];

  @override
  Map<String,String> get tips => {
    "trash1": "Organic trash goes to the brown can",
    "trash2": "Batteries go to the red can",
    "trash3": "Plastic and metal go to the yellow can",
    "trash4": "Paper and cardboard go to the blue can",
    "trash5": "Glass goes to the green can",
    "trash6": "Paper and cardboard go to the blue can",
    "trash7": "Batteries go to the red can",
    "trash8": "Glass goes to the green can",
    "trash9": "Plastic and metal go to the yellow can",
    "trash10": "Organic trash goes to the brown can",
  };

  @override
  Map<String, String> get correctAnswers => {
    "assets/trash1.png": "brown",
    "assets/trash2.png": "red",
    "assets/trash3.png": "yellow",
    "assets/trash4.png": "blue",
    "assets/trash5.png": "green",
    "assets/trash6.png": "blue",
    "assets/trash7.png": "red",
    "assets/trash8.png": "green",
    "assets/trash9.png": "yellow",
    "assets/trash10.png": "brown",
  };
}

void main() {
  late MockGameData binData;
  late Widget testWidget;

  setUp(() {
    binData = MockGameData();
    testWidget = MaterialApp(
      home: BinScreen(binData: binData),
    );
  });

  testWidgets('BinScreen renders all bins and trash items', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    expect(find.byType(DragTarget<String>), findsNWidgets(5));
    expect(find.byType(Draggable<String>), findsNWidgets(4));
  });

  testWidgets('Dropping correct item into correct bin increments correctCount', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    final state = tester.state<BinScreenState>(find.byType(BinScreen));

    fakeAsync((async) {
      final Map<String, String> trashItems = state.trashItems;
      final firstEntry = trashItems.entries.first;
      state.removeTrashItem(firstEntry.key, firstEntry.value, Offset.zero);
      async.elapse(Duration(seconds: 1)); // Simulate time passing

      expect(state.correctCount, 1);
      expect(state.trashItems.containsKey(firstEntry.key), isFalse);
    });
  });

  testWidgets('Dropping wrong item into incorrect bin increments wrongCount', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    final state = tester.state<BinScreenState>(find.byType(BinScreen));

    fakeAsync((async) {
      final Map<String, String> trashItems = state.trashItems;
      final firstEntry = trashItems.entries.first;
      if (firstEntry.value == "blue") {
        state.removeTrashItem(firstEntry.key, "brown", Offset.zero);
      } else {
        state.removeTrashItem(firstEntry.key, "blue", Offset.zero);
      }

      expect(state.wrongCount, 1);
      expect(state.trashItems.containsKey(firstEntry.key), isFalse);
    });
  });

  testWidgets('Game refills trash items from remainingTrashItems after removing one', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    final state = tester.state<BinScreenState>(find.byType(BinScreen));

    fakeAsync((async) {
      final initialRemainingCount = state.remainingTrashItems.length;
      final nextTrash = state.remainingTrashItems.keys.first;

      state.removeTrashItem('trash1', 'brown', Offset.zero); // correct bin
      async.elapse(const Duration(seconds: 1)); // simulate delayed future

      // Now test the state after delay
      expect(state.trashItems.containsKey(nextTrash), isTrue);
      expect(state.remainingTrashItems.length, initialRemainingCount - 1);
    });
  });

  testWidgets('Game is over when all trashItems and remainingTrashItems are empty', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    final state = tester.state<BinScreenState>(find.byType(BinScreen));

    // Clear all items
    state.trashItems.clear();
    state.remainingTrashItems.clear();

    expect(state.isGameOver(), isTrue);
  });

  testWidgets('Test full drag-and-drop game flow', (WidgetTester tester) async {
    // Sample data for the test
    final gameData = GameData(
      gameName: 'Recycle Game',
      gameLogo: 'assets/placeholder.png',
      documentName: 'recycle_test',
      correctAnswers: {
        'assets/trash1.png': 'blue',
        'assets/trash2.png': 'brown',
        'assets/trash3.png': 'green',
        'assets/trash4.png': 'yellow',
        'assets/trash5.png': 'red',
        'assets/trash6.png': 'green',
        'assets/trash7.png': 'blue',
        'assets/trash8.png': 'brown',
        'assets/trash9.png': 'yellow',
        'assets/trash10.png': 'red',
      },
      tips: {
        'assets/trash1.png': 'blue',
        'assets/trash2.png': 'brown',
        'assets/trash3.png': 'green',
        'assets/trash4.png': 'yellow',
        'assets/trash5.png': 'red',
        'assets/trash6.png': 'green',
        'assets/trash7.png': 'blue',
        'assets/trash8.png': 'brown',
        'assets/trash9.png': 'yellow',
        'assets/trash10.png': 'red',
      },
      gameDescription: 'This is my description',
      gameBibliography: 'This is my bibliography',
      tags: [],
      gameTemplate: 'drag',
      public: true,
    );

    final MockDataService mockDataService = MockDataService();

    final MockFirebaseAuth mockAuth = MockFirebaseAuth(signedIn: true,
      mockUser: MockUser(
        uid: 'testStudent',
        email: 'test@example.com',
        displayName: 'Test User',
      ),
    );

    testWidget = MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => MockAuthService(firebaseAuth: mockAuth),
        ),
        Provider<DataService>(create: (_) => mockDataService),
      ],
      child: MaterialApp(
        home: BinScreen(binData: gameData),
      ),
    );

    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    // Helper to get visible trash item
    Finder findTrashItem(String path) => find.byWidgetPredicate(
          (widget) => widget is Image &&
          (widget.image is AssetImage &&
              (widget.image as AssetImage).assetName == path),
    );

    // Perform 10 drag actions for 10 items
    for (int i = 0; i < 10; i++) {
      await tester.pumpAndSettle();

      final binScreenState = tester.state<BinScreenState>(find.byType(BinScreen));
      final trashItems = Map<String, String>.from(binScreenState.trashItems);

      expect(trashItems, isNotEmpty, reason: 'Expected trash items to be present');

      final item = trashItems.keys.first;
      final correctBin = trashItems[item]!;

      final itemFinder = findTrashItem(item);
      expect(itemFinder, findsOneWidget);

      // Find matching bin
      final binFinder = find.byWidgetPredicate((widget) {
        if (widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName.contains('${correctBin}_bin')) {
          return true;
        }
        return false;
      });

      expect(binFinder, findsWidgets); // might be closed/open variants

      // Drag the item to the bin
      await tester.ensureVisible(itemFinder);
      await tester.ensureVisible(binFinder.first);

      final TestGesture gesture = await tester.startGesture(tester.getCenter(itemFinder));
      await tester.pump(); // allow gesture to start

      await gesture.moveTo(tester.getCenter(binFinder.first));
      await tester.pump(); // allow drag to hover

      await gesture.up(); // complete the drop
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    // Final check: ResultsPage should be shown
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(ResultsPage), findsOneWidget);
  });
}
