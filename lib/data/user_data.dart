import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String id;
  final String username;
  final String email;
  final String name;
  final String role;
  final DateTime birthdate;

  UserData({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.role,
    required this.birthdate,
  });

  // From Firestore method with better error handling
  static Future<UserData> fromFirestore(String userId, FirebaseFirestore firestore) async {
    try {
      // Fetch the document from Firestore
      DocumentSnapshot snapshot = await firestore.collection('users').doc(userId).get();

      // Check if the document exists
      if (!snapshot.exists) {
        throw Exception("User not found in Firestore for ID: $userId");
      }

      var data = snapshot.data() as Map<String, dynamic>;

      // Check for the required fields in the data
      if (data['username'] == null || data['email'] == null || data['name'] == null || data['role'] == null || data['birthdate'] == null) {
        throw Exception("Missing required user fields in Firestore document for user ID: $userId");
      }

      // Safely parse the birthdate field and handle potential issues
      var birthdateField = data['birthdate'];
      DateTime birthdateValue;

      // Check if the birthdate is a Timestamp
      if (birthdateField is Timestamp) {
        birthdateValue = birthdateField.toDate();
      } else if (birthdateField is String) {
        // If the birthdate is a String, try to parse it to DateTime
        birthdateValue = DateTime.tryParse(birthdateField) ?? DateTime(2000); // Fallback date if parsing fails
      } else {
        // If the birthdate is neither a Timestamp nor a String, throw an error
        throw Exception("Invalid birthdate format for user ID: $userId");
      }

      // Return the UserData object
      return UserData(
        id: userId,
        username: data['username'] ?? 'Unknown User',
        email: data['email'] ?? 'Unknown Email',
        name: data['name'] ?? 'Unknown Name',
        role: data['role'] ?? 'Unknown Role',
        birthdate: birthdateValue,
      );
    } catch (e) {
      // Log detailed error message and rethrow
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
      'birthdate': birthdate.toIso8601String(), // Convert birthdate to string for caching
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
      birthdate: DateTime.tryParse(data['birthdate'] ?? '') ?? DateTime(2000), // Fallback to 2000 if parsing fails
    );
  }
}
