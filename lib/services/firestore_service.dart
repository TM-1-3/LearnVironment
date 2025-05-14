import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:learnvironment/data/game_data.dart';
import 'package:learnvironment/data/subject_data.dart';
import 'package:learnvironment/data/user_data.dart';

import '../data/assignment_data.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 1. User
  // 2. Games
  // 3. Subjects (Aka Classes)
  // 4. Assignments
  // 5. Events

  //============================== USER =================================================//


  Future<void> updateUserGamesPlayed({required String uid, required String gameId}) async {
    final userDoc = _firestore.collection('users').doc(uid);
    final userSnapshot = await userDoc.get();

    List<String> gamesPlayed = [];

    if (userSnapshot.exists && userSnapshot.data() != null) {
      final data = userSnapshot.data()!;
      gamesPlayed = List<String>.from(data['gamesPlayed'] ?? []);
    }

    gamesPlayed.remove(gameId);
    gamesPlayed.insert(0, gameId);

    try {
      await userDoc.update({'gamesPlayed': gamesPlayed});
      print('[FirestoreService] Updated gamesPlayed for user $uid');

    } catch (e, stackTrace) {
      print('[FirestoreService] Error updating gamesPlayed in Firestore: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<UserData> fetchUserData({required String userId}) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(userId).get();

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
        img: data['img'] ?? 'assets/placeholder.png',
        birthdate: birthdateValue,
        gamesPlayed: List<String>.from(data['gamesPlayed'] ?? []),
        myGames: List<String>.from(data['myGames'] ?? []),
        tClasses: List<String>.from(data['tClasses'] ?? []),
        stClasses: List<String>.from(data['stClasses'] ?? []),
      );
    } catch (e, stackTrace) {
      debugPrint("Error loading UserData: $e\n$stackTrace");
      rethrow;
    }
  }

  Future<bool> checkIfUsernameAlreadyExists(String username) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<String?> getUserIdByUserName(String username) async {
    final snapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id;
    }
    return null;
  }

  Future<String?> fetchUserType({required String uid}) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final data = userDoc.data();
      return data?['role'];
    } catch (e, stackTrace) {
      debugPrint("Error fetching user role: $e\n$stackTrace");
      return null;
    }
  }

  Future<void> setUserInfo({
    required String uid,
    required String name,
    required String username,
    required String selectedAccountType,
    required String email,
    required String birthDate,
    required String img,
    List<String>? stClasses,
    List<String>? tClasses,
    List<String>? gamesPlayed
  }) async {
    try {
      if (selectedAccountType == '') {
        throw Exception("No selected Account Type");
      }
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'username': username,
        'role': selectedAccountType,
        'email': email,
        'birthdate': birthDate,
        'gamesPlayed': gamesPlayed,
        'stClasses': stClasses,
        'tClasses': tClasses,
        'img' : img
      });
      print("[FirestoreService] User Info set!");
    } catch (e) {
      print("[FirestoreService] Unable to set user info!");
      throw Exception("Unable to set user info!");
    }
  }

  Future<void> deleteAccount({required String uid}) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      print("[FirestoreService] Account Deleted");
    } catch (e) {
      print("[FirestoreService] Error deleting account $uid");
      rethrow;
    }
  }



  //========================= GAMES =========================//


  Future<List<Map<String, dynamic>>> getAllGames() async {
    try {
      final querySnapshot = await _firestore.collection('games').get();

      // Filter games where the 'public' field (as a string) is 'true'
      return querySnapshot.docs.where((doc) {
        final data = doc.data();
        return data['public']!.toLowerCase() == 'true'; // Convert string to boolean
      }).map((doc) {
        final data = doc.data();
        return {
          'imagePath': data['logo'] ?? 'assets/placeholder.png',
          'gameTitle': data['name'] ?? 'Default Game Title',
          'tags': List<String>.from(data['tags'] ?? []),
          'gameId': doc.id,
        };
      }).toList();
    } catch (e, stackTrace) {
      debugPrint('Error getting games: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMyGames({required String uid}) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        debugPrint("Error: No user found for UID: $uid");
        return [];
      }

      final data = userDoc.data();
      if (data?.containsKey('myGames') ?? false) {
        final games = data!['myGames'];

        if (games is List) {
          final gameIds = games.whereType<String>().toList();
          if (gameIds.isEmpty) return [];

          final querySnapshot = await _firestore
              .collection('games')
              .where(FieldPath.documentId, whereIn: gameIds)
              .get();

          return querySnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'imagePath': data['logo'] ?? 'assets/placeholder.png',
              'gameTitle': data['name'] ?? 'Default Game Title',
              'tags': List<String>.from(data['tags'] ?? []),
              'gameId': doc.id,
            };
          }).toList();
        } else {
          debugPrint("Error: 'myGames' is not a List.");
          return [];
        }
      } else {
        debugPrint("Error: No 'myGames' field found for user.");
        return [];
      }
    } catch (e, stackTrace) {
      debugPrint("Error fetching user played games: $e\n$stackTrace");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPlayedGames({required String uid}) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        debugPrint("Error: No user found for UID: $uid");
        return [];
      }

      final data = userDoc.data();
      if (data?.containsKey('gamesPlayed') ?? false) {
        final games = data!['gamesPlayed'];

        if (games is List) {
          final gameIds = games.whereType<String>().toList();
          if (gameIds.isEmpty) return [];

          final querySnapshot = await _firestore
              .collection('games')
              .where(FieldPath.documentId, whereIn: gameIds)
              .get();

          return querySnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'imagePath': data['logo'] ?? 'assets/placeholder.png',
              'gameTitle': data['name'] ?? 'Default Game Title',
              'tags': List<String>.from(data['tags'] ?? []),
              'gameId': doc.id,
            };
          }).toList();
        } else {
          debugPrint("Error: 'gamesPlayed' is not a List.");
          return [];
        }
      } else {
        debugPrint("Error: No 'gamesPlayed' field found for user.");
        return [];
      }
    } catch (e, stackTrace) {
      debugPrint("Error fetching user played games: $e\n$stackTrace");
      return [];
    }
  }

  Future<GameData> fetchGameData({required String gameId}) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('games').doc(gameId).get();

      if (!snapshot.exists) {
        throw Exception("Game not found in Firestore for ID: $gameId");
      }

      var data = snapshot.data() as Map<String, dynamic>;

      String template = data['template'] ?? '';
      Map<String, String> tips = {};
      Map<String, List<String>>? questionsAndOptions;
      Map<String, String> correctAnswers = {};

      // If it's a quiz game, extract questions and answers
      if (template == "quiz") {
        try {
          var rawQuestionsAndOptions = Map<String, dynamic>.from(data['questionsAndOptions'] ?? {});
          questionsAndOptions = rawQuestionsAndOptions.map(
                (key, value) => MapEntry(key, List<String>.from(value)),
          );
        } catch (e) {
          throw Exception("Error parsing quiz fields for game $gameId: $e");
        }
      }

      try {
        var rawTips = Map<String, dynamic>.from(data['tips'] ?? {});
        tips = rawTips.map(
              (key, value) => MapEntry(key, value.toString()),
        );

        var rawCorrectAnswers = Map<String, dynamic>.from(data['correctAnswers'] ?? {});
        correctAnswers = rawCorrectAnswers.map(
              (key, value) => MapEntry(key, value.toString()),
        );
      } catch (e) {
        print("Error getting tips");
      }

      return GameData(
        gameLogo: data['logo'] ?? 'default_logo.png',
        gameName: data['name'] ?? 'Unnamed Game',
        gameDescription: data['description'] ?? 'No description available.',
        gameBibliography: data['bibliography'] ?? 'No bibliography available.',
        tags: List<String>.from(data['tags'] ?? []),
        gameTemplate: template,
        documentName: snapshot.id,
        questionsAndOptions: questionsAndOptions,
        correctAnswers: correctAnswers,
        tips: tips,
        public: data['public']!.toLowerCase() == 'true'
      );
    } catch (e, stackTrace) {
      debugPrint("Error loading GameData: $e\n$stackTrace");
      rethrow;
    }
  }

  Future<void> updateGamePublicStatus({required String gameId, required bool status}) async {
    try {
      final gameDoc = _firestore.collection('games').doc(gameId);

      await gameDoc.update({'public': status.toString()});
      print('[FirestoreService] Updated public for game $gameId');
    } catch (e, stackTrace) {
      debugPrint("[FirestoreService] Error updating public: $e\n$stackTrace");
      rethrow;
    }
  }



  // =========================== SUBJECTS (Aka CLASSES) ==============================//


  Future<List<Map<String, dynamic>>> getAllSubjects({required String teacherId}) async {
    try {
      final querySnapshot = await _firestore
          .collection('subjects')
          .where('teacher', isEqualTo: teacherId)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'imagePath': data['logo'] ?? 'assets/placeholder.png',
          'subjectName': data['name'] ?? 'Default Game Title',
          'subjectId': doc.id,
        };
      }).toList();
    } catch (e, stackTrace) {
      debugPrint('[FirestoreService] Error getting subjects: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<SubjectData> fetchSubjectData({required String subjectId}) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('subjects').doc(subjectId).get();

      if (!snapshot.exists) {
        throw Exception("Subject not found in Firestore for ID: $subjectId");
      }

      var data = snapshot.data() as Map<String, dynamic>;

      return SubjectData(
        subjectId: snapshot.id,
        subjectLogo: data['logo'] ?? 'assets/placeholder.png',
        subjectName: data['name'] ?? 'Unknown Name',
        students: List<String>.from(data['students'] ?? []),
        assignments: List<String>.from(data['assignments'] ?? []),
        teacher: data['teacher'],
      );
    } catch (e, stackTrace) {
      debugPrint("Error loading SubjectData: $e\n$stackTrace");
      rethrow;
    }
  }

  Future<bool> checkIfStudentAlreadyInClass({required String subjectId, required String studentId}) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('subjects').doc(
          subjectId).get();

      if (!snapshot.exists) {
        throw Exception("Subject not found in Firestore for ID: $subjectId");
      }

      var data = snapshot.data() as Map<String, dynamic>;

      List<String> students = List<String>.from(data['students']);
      for (String student in students) {
        if (student == studentId) {
          return true;
        }
      }
      return false;
    } catch (e, stackTrace) {
      debugPrint("Error loading checking if student already in class: $e\n$stackTrace");
      rethrow;
    }
  }

  Future<void> addSubjectData({required SubjectData subject, required String uid}) async {
    await _firestore
        .collection('subjects')
        .doc(subject.subjectId)
        .set({
      'subjectId': subject.subjectId,
      'name': subject.subjectName,
      'logo': subject.subjectLogo,
      'teacher': uid,
      'students': subject.students,
      'assignments': subject.assignments,
    });

    final userDoc = _firestore.collection('users').doc(uid);
    final userSnapshot = await userDoc.get();

    List<String> classes = [];

    if (userSnapshot.exists && userSnapshot.data() != null) {
      final data = userSnapshot.data()!;
      classes = List<String>.from(data['tClasses'] ?? []);
    }

    classes.remove(subject.subjectId);
    classes.insert(0, subject.subjectId);

    try {
      await userDoc.update({'tClasses': classes});
      print('[FirestoreService] Updated classes for user $uid');

    } catch (e, stackTrace) {
      print('[FirestoreService] Error updating classes in Firestore: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> deleteSubject({required String subjectId, required String uid}) async {
    try {
      await _firestore.collection('subjects').doc(subjectId).delete();
      final userDoc = _firestore.collection('users').doc(uid);
      final userSnapshot = await userDoc.get();

      List<String> classes = [];
      List<String> stClasses = [];
      List<String> tClasses = [];

      if (userSnapshot.exists && userSnapshot.data() != null) {
        final data = userSnapshot.data()!;
        classes = List<String>.from(data['classes'] ?? []);
        stClasses = List<String>.from(data['stClasses'] ?? []);
        tClasses = List<String>.from(data['tClasses'] ?? []);
      }

      classes.remove(subjectId);
      stClasses.remove(subjectId);
      tClasses.remove(subjectId);

      await userDoc.update({'classes': classes});
      await userDoc.update({'stClasses': stClasses});
      await userDoc.update({'tClasses': tClasses});
      print("[FirestoreService] Class Deleted");
    } catch (e) {
      print("[FirestoreService] Error deleting class $subjectId");
      rethrow;
    }
  }

  Future<void> addStudentToSubject({required String subjectId, required String studentId}) async {
    try {
      final subjectRef = _firestore.collection('subjects').doc(subjectId);
      final userRef = _firestore.collection('users').doc(studentId);
      await subjectRef.update({
        'students': FieldValue.arrayUnion([studentId]),
      });
      await userRef.update({
        'stClasses': FieldValue.arrayUnion([subjectId]),
      });
      print("[FirestoreService] Added student $studentId to subject $subjectId");
    } catch (e, stackTrace) {
      print("[FirestoreService] Error adding student to subject: $e\n$stackTrace");
      rethrow;
    }
  }

  Future<void> removeStudentFromSubject({
    required String subjectId,
    required String studentId,
  }) async {
    try {
      final subjectRef = _firestore.collection('subjects').doc(subjectId);

      await subjectRef.update({
        'students': FieldValue.arrayRemove([studentId]),
      });

      print("[FirestoreService] Removed student $studentId from subject $subjectId");
    } catch (e, stackTrace) {
      print("[FirestoreService] Error removing student from subject: $e\n$stackTrace");
      rethrow;
    }
  }



  //================================ ASSIGNMENTS ====================================//


  Future<String> createAssignment({
    required String title,
    required String gameId,
    required String turma,
    required String dueDate,
  }) async {
    try {
      if (turma== '') {
        throw Exception("No class selected");
      }

      await _firestore.collection('events').add({
        'name': 'New Assignment!',
        'className': turma,
      });

      DocumentReference docRef = await _firestore.collection('assignment').add({
        'title': title,
        'gameId': gameId,
        'class': turma,
        'dueDate': dueDate,
      });

      final assignmentDoc = _firestore.collection('subjects').doc(turma);
      final assignmentSnapshot = await assignmentDoc.get();

      List<String> assignments = [];

      if (assignmentSnapshot.exists && assignmentSnapshot.data() != null) {
        final data = assignmentSnapshot.data()!;
        assignments = List<String>.from(data['assignments'] ?? []);
      }

      assignments.remove(docRef.id);
      assignments.insert(0, docRef.id);

      await assignmentDoc.update({'assignments': assignments});
      print("[FirestoreService] Created Assignment!");
      return docRef.id;
    } catch (e) {
      print("[FirestoreService] Unable to create assignment!");
      throw Exception("Unable to create assignment!");
    }
  }

  Future<AssignmentData> fetchAssignmentData({required String assignmentId}) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('assignment').doc(assignmentId).get();

      if (!snapshot.exists) {
        throw Exception("Assignment not found in Firestore for ID: $assignmentId");
      }

      var data = snapshot.data() as Map<String, dynamic>;

      return AssignmentData(
          assId: assignmentId,
          subjectId: data['subjectId'] ?? 'unknown',
          gameId: data['gameId'] ?? 'Unknown',
          title: data['title'] ?? 'Unknown Name',
          dueDate: data['dueDate'] ?? ' '
      );
    } catch (e, stackTrace) {
      debugPrint("Error loading AssignmentData: $e\n$stackTrace");
      rethrow;
    }
  }

  Future<void> deleteAssignment({required String assignmentId, required String uid}) async {
    try {
      await _firestore.collection('assignment').doc(assignmentId).delete();
      final classDoc = _firestore.collection('subjects').doc(uid);
      final classSnapshot = await classDoc.get();

      List<String> assignments = [];

      if (classSnapshot.exists && classSnapshot.data() != null) {
        final data = classSnapshot.data()!;
        assignments = List<String>.from(data['assignments'] ?? []);
      }

      assignments.remove(assignmentId);

      await classDoc.update({'assignments': assignments});
      print("[FirestoreService] Assignment Deleted");
    } catch (e) {
      print("[FirestoreService] Error deleting assignment $assignmentId");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllAssignments() async {
    try {
      final querySnapshot = await _firestore
          .collection('assignment')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'title': data['title'] ?? 'Default Assignment Title',
          'assignmentId': doc.id,
          'subjectId': data['subjectId'] ?? 'Default Subject',
          'gameId': data['gameId'] ?? 'Unknown',
          'dueDate': data['dueDate'] ?? ' '
        };
      }).toList();
    } catch (e, stackTrace) {
      debugPrint('[FirestoreService] Error getting assignments: $e\n$stackTrace');
      rethrow;
    }
  }



//================================ EVENTS ====================================//


  Future<List<RemoteMessage>> fetchNotifications({required String uid}) async {
    UserData userData = await fetchUserData(userId: uid);

    List<RemoteMessage> notifications = [];

    List<String> myClasses = userData.role == "student" ? userData.stClasses : userData.tClasses;

    for (String myClass in myClasses) {
      SubjectData subjectData = await fetchSubjectData(subjectId: myClass);

      for (String ass in subjectData.assignments) {
        AssignmentData assignmentData = await fetchAssignmentData(assignmentId: ass);
        RemoteMessage message = RemoteMessage(
          notification: RemoteNotification(
            title: "Assignment: ${assignmentData.title}",
            body: "Due Date: ${assignmentData.dueDate}",
          ),
          data: {
            'gameId': assignmentData.gameId,
            'subjectId': assignmentData.subjectId,
            'assId': assignmentData.assId,
          },
        );
        notifications.add(message);
      }
    }
    return notifications;
  }
}