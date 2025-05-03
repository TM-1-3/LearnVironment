import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/authentication/login_screen.dart';
import 'package:learnvironment/authentication/signup_screen.dart';
import 'package:learnvironment/main_pages/edit_profile_screen.dart';
import 'package:learnvironment/main_pages/profile_screen.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/data/user_data.dart';
import 'package:learnvironment/services/user_cache_service.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockUserCache extends Mock implements UserCacheService {
  @override
  Future<void> clearUserCache() async {}
}

class MockAuthService extends Mock implements AuthService {
  late String uid;

  MockAuthService({MockFirebaseAuth? firebaseAuth}) {
    uid = firebaseAuth?.currentUser?.uid ?? '';
  }

  @override
  Future<String> getUid() async {
    return uid;
  }

  @override
  Future<void> deleteAccount({required String password}) async {}

  @override
  Future<void> signOut() async {}

  @override
  Stream<User?> get authStateChanges => Stream.value(MockUser());
}

class MockDataService extends Mock implements DataService {
  @override
  Future<void> deleteAccount({required String uid}) async {}

  @override
  Future<UserData?> getUserData({required String userId}) async {
    if (userId == 'error') {
      return null;
    }
    return UserData(
      name: "John Doe",
      username: "johndoe",
      email: "john@example.com",
      img: "assets/placeholder.png",
      birthdate: DateTime(2000, 1, 1),
      role: "student",
      id: userId,
      gamesPlayed: [],
      tClasses: [],
      stClasses: []
    );
  }
}

void main() async {
  late MockFirebaseAuth auth;
  late Widget testWidget;
  late MockAuthService authService;
  late MockUserCache userCache;
  late MockDataService dataService;

  setUp(() async {
    auth = MockFirebaseAuth(mockUser: MockUser(uid: 'test', email: 'john@example.com'), signedIn: true);
    authService = MockAuthService(firebaseAuth: auth);
    userCache = MockUserCache();
    dataService = MockDataService();

    testWidget = MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
            create: (_) => authService),
        Provider<DataService>(create: (context) => dataService),
        Provider<UserCacheService>(create: (context) => userCache),
      ],
      child: MaterialApp(
        home: ProfileScreen(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignUpScreen()
        },
      ),
    );
  });

  testWidgets('renders user profile data correctly', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('johndoe'), findsOneWidget);
    expect(find.text('john@example.com'), findsOneWidget);
  });

  testWidgets('signs out', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byIcon(Icons.exit_to_app));
    await tester.tap(find.byIcon(Icons.exit_to_app));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Deletes account', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byIcon(Icons.delete_forever));
    await tester.tap(find.byIcon(Icons.delete_forever));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure?'), findsOneWidget);
    await tester.ensureVisible(find.text("Delete"));
    await tester.tap(find.text("Delete"));
    await tester.pumpAndSettle();

    expect(find.text('Re-authentication required'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'test_password');
    await tester.pumpAndSettle();
    await tester.tap(find.text("OK"));
    await tester.pumpAndSettle();

    expect(find.byType(SignUpScreen), findsOneWidget);
  });

  testWidgets('Decides not to delete account', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byIcon(Icons.delete_forever));
    await tester.tap(find.byIcon(Icons.delete_forever));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure?'), findsOneWidget);
    await tester.ensureVisible(find.text("Cancel"));
    await tester.tap(find.text("Cancel"));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets('shows error text if snapshot has error', (WidgetTester tester) async {
    auth = MockFirebaseAuth(mockUser: MockUser(uid: 'error', email: 'john@example.com'), signedIn: true);
    authService = MockAuthService(firebaseAuth: auth);
    testWidget = MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
            create: (_) => authService),
        Provider<DataService>(create: (context) => dataService),
        Provider<UserCacheService>(create: (context) => userCache),
      ],
      child: MaterialApp(
        home: ProfileScreen(),
        routes: {
          '/login': (context) => LoginScreen()
        },
      ),
    );

    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('navigates to EditProfilePage on edit icon press', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byIcon(Icons.edit));
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    expect(find.byType(EditProfilePage), findsOneWidget);
  });
}
