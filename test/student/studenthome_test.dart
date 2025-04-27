import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/student/student_home.dart';
import 'package:learnvironment/student/student_main_page.dart';
import 'package:learnvironment/main_pages/games_page.dart';
import 'package:learnvironment/main_pages/profile_screen.dart';
import 'package:learnvironment/student/student_stats.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockDataService extends Mock implements DataService {
  @override
  Future<UserData?> getUserData({required String userId}) {
      return Future.value(UserData(role: '', id: '', username: '', name: '', email: '', birthdate: DateTime(2000, 1, 1, 0, 0, 0, 0, 0), gamesPlayed: [], classes: [], img: 'assets/placeholder.png'));
  }
}

void main() {
  late MockFirebaseAuth mockAuth;
  late Widget testWidget;
  late MockDataService mockDataService;

  setUp(() {
    mockAuth = MockFirebaseAuth(mockUser: MockUser(uid: 'test', displayName: 'Test', email: 'email'), signedIn: true);
    mockDataService = MockDataService();
    testWidget = MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(firebaseAuth: mockAuth),
        ),
        Provider<DataService>(create: (_) => mockDataService),
      ],
      child: MaterialApp(
          home: StudentHomePage()
      ),
    );
  });

  group('StudentHomePage Widget Tests', () {
    testWidgets('Displays default Home page content', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.text('LearnVironment'), findsOneWidget);
      expect(find.byType(StudentMainPage), findsOneWidget);
    });

    testWidgets('Navigates to StudentStatsPage page', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.byIcon(Icons.pie_chart));
      await tester.pumpAndSettle();

      expect(find.byType(StudentStatsPage), findsOneWidget);
    });

    testWidgets('Navigates to Games page', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.byIcon(Icons.videogame_asset));
      await tester.pumpAndSettle();

      expect(find.byType(GamesPage), findsOneWidget);
    });

    testWidgets('Navigates to ProfileScreen page', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsOneWidget);
    });
  });
}
