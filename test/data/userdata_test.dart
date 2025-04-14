import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:learnvironment/data/user_data.dart';

void main() {
  late FirebaseFirestore firestore;

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  test('UserData fetches user data correctly', () async {
    // Sample user data
    final userData = {
      'username': 'Lebi',
      'email': 'up202307719@g.uporto.pt',
      'name': 'L',
      'role': 'developer',
      'birthdate': Timestamp.fromDate(DateTime(2000, 1, 1)),
    };

    // Set up Firestore with user data
    await firestore.collection('users').doc('user1').set(userData);

    // Fetch user data
    UserData user = await UserData.fromFirestore('user1', firestore);

    // Verify the fetched data
    expect(user.username, 'Lebi');
    expect(user.email, 'up202307719@g.uporto.pt');
    expect(user.name, 'L');
    expect(user.role, 'developer');
    expect(user.birthdate, DateTime(2000, 1, 1));
  });

  test('User not found exception', () async {
    try {
      // Attempt to fetch a user that does not exist
      await UserData.fromFirestore('non_existing_user', firestore);
      fail('Expected an exception to be thrown');
    } catch (e) {
      // Verify that the exception is thrown
      expect(e.toString(), contains('User not found!'));
    }
  });

  test('fetchUserData should return valid UserData', () async {
    final userData = {
      'username': 'Lebi',
      'email': 'up202307719@g.uporto.pt',
      'name': 'L',
      'role': 'developer',
      'birthdate': Timestamp.fromDate(DateTime(2000, 1, 1)),
    };
    await firestore.collection('users').doc('user2').set(userData);

    UserData userDataFetched = await UserData.fromFirestore('user2', firestore);

    expect(userDataFetched.username, 'Lebi');
    expect(userDataFetched.email, 'up202307719@g.uporto.pt');
    expect(userDataFetched.name, 'L');
    expect(userDataFetched.role, 'developer');
    expect(userDataFetched.birthdate, DateTime(2000, 1, 1));
  });
}