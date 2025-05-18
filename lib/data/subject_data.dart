import 'dart:convert';

class SubjectData {
  final String subjectId;
  final String subjectLogo;
  final String subjectName;
  final String teacher;
  final List<Map<String,dynamic>> students;
  late List<String> assignments;

  SubjectData({
    required this.subjectId,
    required this.subjectLogo,
    required this.subjectName,
    required this.teacher,
    required this.students,
    required this.assignments,
  });

  // Convert to cache format: Only serialize quiz fields if applicable
  Map<String, String> toCache() {
    final Map<String, String> cacheData = {
      'subjectId': subjectId,
      'subjectName': subjectName,
      'subjectLogo': subjectLogo,
      'teacher': teacher,
      'students': jsonEncode(students),
      'assignments': jsonEncode(assignments)
    };

    return cacheData;
  }

  // Deserialize from cache
  factory SubjectData.fromCache(Map<String, String> data) {
    return SubjectData(
      subjectId: data['subjectId'] ?? '',
      subjectLogo: data['subjectLogo'] ?? '',
      subjectName: data['subjectName'] ?? '',
      teacher: data['teacher'] ?? '',
      students: List<Map<String,dynamic>>.from(jsonDecode(data['students'] ?? '[]')),
      assignments: List<String>.from(jsonDecode(data['assignments'] ?? '[]')),
    );
  }
}
