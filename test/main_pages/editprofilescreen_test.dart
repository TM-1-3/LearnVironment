import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  Future<void> updateUsername({required String newUsername}) async {}

  @override
  Future<void> updateEmail({required String newEmail, required String password}) async {}

  @override
  Stream<User?> get authStateChanges => Stream.value(MockUser());
}

class MockDataService extends Mock implements DataService {
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
      myGames: [],
      tClasses: [],
      stClasses: [],
    );
  }

  @override
  Future<void> updateUserProfile({
    required String birthDate,
    required String name,
    required String username,
    required String email,
    required String img,
    required String role,
    required String uid}) async {}
}

void main() async {
  late MockFirebaseAuth auth;
  late Widget testWidget;
  late MockAuthService authService;
  late MockUserCache userCache;
  late MockDataService dataService;
  late UserData userData;

  setUp(() async {
    auth = MockFirebaseAuth(mockUser: MockUser(uid: 'test', email: 'john@example.com'), signedIn: true);
    authService = MockAuthService(firebaseAuth: auth);
    userCache = MockUserCache();
    dataService = MockDataService();

    userData = UserData(
      name: "John Doe",
      username: "johndoe",
      email: "john@example.com",
      img: "assets/placeholder.png",
      birthdate: DateTime(2000, 1, 1),
      role: "student",
      id: "test",
      gamesPlayed: [],
      myGames: [],
      tClasses: [],
      stClasses: [],
    );

    testWidget = MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => authService),
        Provider<DataService>(create: (context) => dataService),
        Provider<UserCacheService>(create: (context) => userCache),
      ],
      child: MaterialApp(
        home: EditProfilePage(userData: userData),
      ),
    );
  });

  testWidgets('renders EditProfilePage with form fields', (tester) async {
    await tester.pumpWidget(testWidget);

    expect(find.byType(TextField), findsNWidgets(5));
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('allows text input in form fields', (tester) async {
    await tester.pumpWidget(testWidget);

    await tester.enterText(find.byType(TextField).at(0), 'New Name');
    await tester.enterText(find.byType(TextField).at(1), 'newusername');
    await tester.enterText(find.byType(TextField).at(2), 'newemail@example.com');
    await tester.enterText(find.byType(TextField).at(3), 'http://newimage.com');

    expect(find.text('New Name'), findsOneWidget);
    expect(find.text('newusername'), findsOneWidget);
    expect(find.text('newemail@example.com'), findsOneWidget);
    expect(find.text('http://newimage.com'), findsOneWidget);
  });

  testWidgets('opens date picker and selects a date', (tester) async {
    await tester.pumpWidget(testWidget);

    final dateField = find.byKey(Key("birthDate"));
    await tester.ensureVisible(dateField);
    await tester.pumpAndSettle();
    await tester.tap(dateField);
    await tester.pumpAndSettle();
    expect(find.byType(CalendarDatePicker), findsOneWidget);

    //Select Year
    await tester.ensureVisible(find.text('January 2000'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('January 2000'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('1993'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1993'));
    await tester.pumpAndSettle();

    //Select Date
    await tester.ensureVisible(find.text('20'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();

    //Enter Date
    await tester.ensureVisible(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, '1993-01-20'), findsOneWidget);
  });

  testWidgets('selects account type from dropdown', (tester) async {
    await tester.pumpWidget(testWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('teacher').last);
    await tester.pumpAndSettle();

    expect(find.text('teacher'), findsOneWidget);
  });

  testWidgets('submits form with valid data', (tester) async {
    await tester.pumpWidget(testWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Updated Name');
    await tester.enterText(find.byType(TextField).at(1), 'updatedusername');
    await tester.enterText(find.byType(TextField).at(2), 'updatedemail@example.com');
    await tester.enterText(find.byType(TextField).at(3), 'https://letsenhance.io/static/73136da51c245e80edc6ccfe44888a99/1015f/MainBefore.jpg');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}