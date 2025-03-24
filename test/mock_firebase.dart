// mock_firebase.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

// Mock FirebaseAuth class
class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  Stream<User?> authStateChanges() {
    return super.noSuchMethod(
      Invocation.method(#authStateChanges, []),
      returnValue: Stream.value(
          null), // Return null for unauthenticated user by default
    );
  }
  @override
  Future<void> signOut() async {
    return Future.value();  // Returns a Future<void> as expected by Firebase's signOut
  }
}

// Mock User class
class MockUser extends Mock implements User {}
