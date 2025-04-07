import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:learnvironment/bin.dart';
import 'package:learnvironment/auth_service.dart';

import 'mock_firebase.dart';

void main() {
  late AuthService authService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late BinScreenState screenState;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();

    // Setup top-level mock before using in constructors
    authService = AuthService(firebaseAuth: mockFirebaseAuth);

    // Stub return values separately
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('testuid');
  });

  testWidgets('Test removeTrashItem with correct bin', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthService>.value(
          value: authService,
          child: BinScreen(authService: authService),
        ),
      ),
    );

    screenState = tester.state(find.byType(BinScreen)) as BinScreenState;

    screenState.trashItems = {'item1': 'bin1'};
    screenState.remainingTrashItems = {'item3': 'bin3'};
    screenState.correctCount = 0;
    screenState.wrongCount = 0;

    screenState.removeTrashItem('item1', 'bin1', const Offset(100, 100));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(screenState.trashItems.containsKey('item1'), isFalse);
    expect(screenState.correctCount, 1);
    expect(screenState.wrongCount, 0);
    expect(screenState.showIcon, isFalse);
    expect(screenState.rightAnswer, isTrue);
  });

  testWidgets('Test removeTrashItem with incorrect bin', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthService>.value(
          value: authService,
          child: BinScreen(authService: authService),
        ),
      ),
    );

    screenState = tester.state(find.byType(BinScreen)) as BinScreenState;

    screenState.trashItems = {'item1': 'bin1'};
    screenState.remainingTrashItems = {'item3': 'bin3'};
    screenState.correctCount = 0;
    screenState.wrongCount = 0;

    screenState.removeTrashItem('item1', 'bin2', const Offset(200, 200));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(screenState.trashItems.containsKey('item1'), isFalse);
    expect(screenState.correctCount, 0);
    expect(screenState.wrongCount, 1);
    expect(screenState.showIcon, isFalse);
    expect(screenState.rightAnswer, isFalse);
  });

  testWidgets('Test removeTrashItem with no remaining trash', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthService>.value(
          value: authService,
          child: BinScreen(authService: authService),
        ),
      ),
    );

    screenState = tester.state(find.byType(BinScreen)) as BinScreenState;

    screenState.trashItems = {'item1': 'bin1'};
    screenState.remainingTrashItems.clear();
    screenState.correctCount = 0;
    screenState.wrongCount = 0;

    screenState.removeTrashItem('item1', 'bin1', const Offset(300, 300));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(screenState.trashItems.isEmpty, isTrue);
    expect(screenState.correctCount, 1);
    expect(screenState.wrongCount, 0);
    expect(screenState.showIcon, isFalse);
    expect(screenState.rightAnswer, isTrue);
  });
}
