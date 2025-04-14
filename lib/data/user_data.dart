import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String id;
  final String username;
  final String email;
  final String name;
  final String role;
  final DateTime birthdate;
  final List<String> gamesPlayed;

  UserData({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.role,
    required this.birthdate,
    this.gamesPlayed = const [],
  });

  // From Firestore method with better error handling
  static Future<UserData> fromFirestore(String userId, FirebaseFirestore firestore) async {
    try {
      DocumentSnapshot snapshot = await firestore.collection('users').doc(userId).get();

      if (!snapshot.exists) {
        throw Exception("User not found in Firestore for ID: $userId");
      }

      var data = snapshot.data() as Map<String, dynamic>;

      var birthdateField = data['birthdate'];
      DateTime birthdateValue;

      if (birthdateField is Timestamp) {
        birthdateValue = birthdateField.toDate();
      } else if (birthdateField is String) {
        birthdateValue = DateTime.tryParse(birthdateField) ?? DateTime(2000);
      } else {
        birthdateValue = DateTime(2000);
      }

      return UserData(
        id: userId,
        username: data['username'] ?? 'Unknown User',
        email: data['email'] ?? 'Unknown Email',
        name: data['name'] ?? 'Unknown Name',
        role: data['role'] ?? 'Unknown Role',
        birthdate: birthdateValue,
        gamesPlayed: List<String>.from(data['gamesPlayed'] ?? []),
      );
    } catch (e) {
      print('Error loading user data for userId: $userId: $e');
      throw Exception("Error getting data from Firestore for userId: $userId: $e");
    }
  }

  // Method to convert UserData to cache format
  Map<String, String> toCache() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'role': role,
      'birthdate': birthdate.toIso8601String(),
      'gamesPlayed': gamesPlayed.join(','),
    };
  }

  // Cache recovery with default fallbacks in case of missing or malformed data
  factory UserData.fromCache(Map<String, String> data) {
    return UserData(
      id: data['id'] ?? '',
      username: data['username'] ?? 'Unknown User',
      email: data['email'] ?? 'Unknown Email',
      name: data['name'] ?? 'Unknown Name',
      role: data['role'] ?? 'Unknown Role',
      birthdate: DateTime.tryParse(data['birthdate'] ?? '') ?? DateTime(2000),
      gamesPlayed: (data['gamesPlayed']?.split(',') ?? []),
    );
  }

  // CopyWith method to create a new UserData instance with modified fields
  UserData copyWith({
    String? id,
    String? username,
    String? email,
    String? name,
    String? role,
    DateTime? birthdate,
    List<String>? gamesPlayed,
  }) {
    return UserData(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      birthdate: birthdate ?? this.birthdate,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,  // Modify gamesPlayed if needed
    );
  }
}
