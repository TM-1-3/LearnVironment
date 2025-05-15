class UserData {
  final String id;
  final String username;
  final String email;
  final String name;
  final String role;
  final DateTime birthdate;
  final List<String> gamesPlayed;
  final List<String> myGames;
  final String img;
  late List<String> stClasses;
  late List<String> tClasses;

  UserData({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.role,
    required this.birthdate,
    required this.gamesPlayed,
    required this.myGames,
    required this.img,
    required this.tClasses, //teacher classes
    required this.stClasses //student classes
  });

  // Convert UserData to a Map for cache storage
  Map<String, String> toCache() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'role': role,
      'birthdate': birthdate.toIso8601String(),
      'gamesPlayed': gamesPlayed.join(','),
      'myGames': myGames.join(','),
      'tClasses': tClasses.join(','),
      'stClasses': stClasses.join(','),
      'img': img,
    };
  }

  // Convert Map back to UserData (factory method)
  factory UserData.fromCache(Map<String, String> data) {
    return UserData(
        id: data['id'] ?? '',
        username: data['username'] ?? 'Unknown User',
        email: data['email'] ?? 'Unknown Email',
        name: data['name'] ?? 'Unknown Name',
        role: data['role'] ?? 'Unknown Role',
        birthdate: DateTime.tryParse(data['birthdate'] ?? '') ?? DateTime(2000),
        gamesPlayed: (data['gamesPlayed']?.split(',') ?? []),
        myGames: (data['myGames']?.split(',') ?? []),
        tClasses: (data['tClasses']?.split(',') ?? []),
        stClasses: (data['stClasses']?.split(',') ?? []),
        img: data['img'] ?? 'assets/placeholder.png',
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
    List<String>? myGames,
    String? img,
    List<String>? tClasses,
    List<String>? stClasses,
  }) {
    return UserData(
        id: id ?? this.id,
        username: username ?? this.username,
        email: email ?? this.email,
        name: name ?? this.name,
        role: role ?? this.role,
        birthdate: birthdate ?? this.birthdate,
        gamesPlayed: gamesPlayed ?? this.gamesPlayed,
        myGames: myGames ?? this.myGames,
        img: img ?? this.img,
        stClasses: stClasses ?? this.stClasses,
        tClasses: tClasses ?? this.tClasses
    );
  }
}