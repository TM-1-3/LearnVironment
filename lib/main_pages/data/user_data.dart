import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String userName;
  final String email;
  final String name;
  final String role;
  final DateTime birthdate;

  UserData({
    required this.userName,
    required this.email,
    required this.name,
    required this.role,
    required this.birthdate,
  });

  static Future<UserData> fromFirestore(String userId, FirebaseFirestore firestore) async {
    try {
      DocumentSnapshot snapshot = await firestore.collection('users').doc(userId).get();

      if (!snapshot.exists) {
        throw Exception("User not found!");
      }

      var data = snapshot.data() as Map<String, dynamic>;

      return UserData(
        userName: data['username'],
        email: data['email'],
        name: data['name'],
        role: data['role'],
        birthdate: (data['birthdate'] as Timestamp).toDate(),  // Convert Firestore Timestamp to DateTime
      );
    } catch (e) {
      throw Exception("Error getting data from Firestore: $e");
    }
  }
}

Future<UserData> fetchUserData(String userId, {FirebaseFirestore? firestore}) async {
  try {
    firestore ??= FirebaseFirestore.instance;
    return await UserData.fromFirestore(userId, firestore);
  } catch (e) {
    throw Exception("Error loading data from Firestore: $e");
  }
}
