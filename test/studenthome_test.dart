import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/student/student_home.dart';
import 'package:learnvironment/main_pages/main_page.dart';
import 'package:learnvironment/main_pages/games_page.dart';
import 'package:learnvironment/main_pages/statistics_page.dart';
import 'package:learnvironment/main_pages/profile_screen.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late Widget testWidget;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    testWidget = MaterialApp(
      home: StudentHomePage(
        firestore: fakeFirestore,
        auth: mockAuth,
      ),
    );
  });

  group('StudentHomePage Widget Tests', () {
    testWidgets('Displays default Home page content', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.text('LearnVironment'), findsOneWidget);
      expect(find.byType(MainPage), findsOneWidget);
    });

    testWidgets('Navigates to Statistics page', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.byIcon(Icons.pie_chart));
      await tester.pumpAndSettle();

      expect(find.byType(StatisticsPage), findsOneWidget);
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
