import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/authentication/auth_gate.dart';
import 'package:learnvironment/games_templates/results_page.dart';
import 'package:mockito/mockito.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:provider/provider.dart';

class MockDataService extends Mock implements DataService {
  @override
  Future<UserData?> getUserData({required String userId}) {
    return Future.value(UserData(role: '', id: '', username: '', name: '', email: '', birthdate: DateTime(2000, 1, 1, 0, 0, 0, 0, 0), gamesPlayed: [], classes: [], img: ''));
  }
}

class MockAuthGate extends AuthGate {
  MockAuthGate({key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Mock AuthGate Screen'),
      ),
    );
  }
}

void main() {

  group('ResultsPage Tests', ()
  {
    late Widget testWidget;
    late MockDataService mockDataService;
    late MockFirebaseAuth mockAuth;

    setUp(() async {
      mockAuth = MockFirebaseAuth(
          mockUser: MockUser(uid: 'test', displayName: 'Test', email: 'email'),
          signedIn: true);
      mockDataService = MockDataService();
      testWidget = MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(firebaseAuth: mockAuth),
          ),
          Provider<DataService>(create: (_) => mockDataService),
        ],
        child: MaterialApp(
          home: ResultsPage(
              questionsCount: 10,
              correctCount: 8,
              wrongCount: 2,
              gameName: 'EcoMind Challenge',
              gameImage: 'assets/quizLogo.png',
              tipsToAppear: ['Tip1', 'Tip2', 'Tip3'],
              duration: const Duration(minutes: 2, seconds: 10),
              onReplay: () => RandomGame()
          ),
            routes: {
              '/auth_gate': (context) => MockAuthGate(),
            }
        ),
      );
    });

    testWidgets('renders results and feedback', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.text('EcoMind Challenge Results'), findsOneWidget);
      expect(find.text('✅ Correct Answers: 8'), findsOneWidget);
      expect(find.text('❌ Wrong Answers: 2'), findsOneWidget);
      expect(find.textContaining('🕒 Time Taken: 2:10'), findsOneWidget);

      await tester.tap(find.text('Feedback'));
      await tester.pumpAndSettle();

      expect(find.text('Tip1'), findsOneWidget);
      expect(find.text('Tip2'), findsOneWidget);
      expect(find.text('Tip3'), findsOneWidget);
    });

    testWidgets(
        'play again button navigates to new game', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      final playAgainBtn = find.widgetWithText(GestureDetector, 'Play Again');
      expect(playAgainBtn, findsOneWidget);

      await tester.ensureVisible(playAgainBtn);
      await tester.tap(playAgainBtn);
      await tester.pumpAndSettle();

      expect(find.byType(RandomGame), findsOneWidget);
    });

    testWidgets('back to games page button navigates correctly', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      final backToGamesBtn = find.widgetWithText(GestureDetector, 'Exit');
      expect(backToGamesBtn,findsOneWidget);
      await tester.ensureVisible(backToGamesBtn);
      await tester.tap(backToGamesBtn);
      await tester.pumpAndSettle();
      expect(find.byType(MockAuthGate), findsOneWidget);
    });
  });
}

class RandomGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Random Game')),
    );
  }
}