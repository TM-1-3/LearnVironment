import 'package:firebase_core/firebase_core.dart';
import 'package:learnvironment/authentication/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/authentication/firebase_options.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

// Mock FirebaseAuth
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

// Mock User from FirebaseAuth
class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    // Initialize the mocks and FakeFirestore instance before each test
    mockAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('AuthGate - fetchUserType', () {
    test('fetchUserType returns the correct user role', () async {
      final uid = 'gY2EEgnuhcRUMjSaOJnJRz1OnPo1';

      // Explicitly create the document with 'role' field in Firestore mock
      await fakeFirestore.collection('users').doc(uid).set({
        'role': 'developer', // Mock user role in Firestore
      });

      // Create a mock user
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn(uid);
      when(() => mockUser.email).thenReturn('up202307719@g.uporto.pt');

      // Mock FirebaseAuth to return the mock user
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      // Create an instance of AuthGate and pass the fakeFirestore
      final authGate = AuthGate(firestore: fakeFirestore);

      // Call fetchUserType method with uid to retrieve the role
      final userRole = await authGate.fetchUserType(uid);

      // Assert that the role is 'developer' (the role we set above)
      expect(userRole, 'developer');
    });

    test('fetchUserType returns null when no user is found', () async {
      final uid = 'test_uid';

      // Create an instance of AuthGate and test when no user is found in Firestore
      final authGate = AuthGate(firestore: fakeFirestore);
      final userRole = await authGate.fetchUserType(uid);

      // Validate that the role is null when no user is found in Firestore
      expect(userRole, null);
    });

    test('fetchUserType handles errors', () async {
      // Initialize FakeFirebaseFirestore
      final fakeFirestore = FakeFirebaseFirestore();

      // Create an instance of AuthGate using the fake Firestore
      final authGate = AuthGate(firestore: fakeFirestore);

      // Simulate a Firestore error by attempting to fetch data from a non-existent document
      final uid = 'non_existent_uid'; // This UID doesn't exist in Firestore
      fakeFirestore
          .collection('users')
          .doc(uid)
          .set({'role': null}); // Add invalid data to simulate error scenario

      // Ensure fetchUserType gracefully handles errors or invalid data
      final userRole = await authGate.fetchUserType(uid);

      // Validate that the error is handled and fetchUserType returns null
      expect(userRole, null);
    });
  });
}
