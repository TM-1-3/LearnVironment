import 'dart:convert';

class SubjectData {
  final String subjectId;
  final String subjectLogo;
  final String subjectName;
  final String teacher;
  final List<String> students;

  SubjectData({
    required this.subjectId,
    required this.subjectLogo,
    required this.subjectName,
    required this.teacher,
    required this.students
  });

  // Convert to cache format: Only serialize quiz fields if applicable
  Map<String, String> toCache() {
    final Map<String, String> cacheData = {
      'subjectId': subjectId,
      'subjectName': subjectName,
      'subjectLogo': subjectLogo,
      'teacher': teacher,
      'students': jsonEncode(students),
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
      students: data['students'] != null
          ? List<String>.from(jsonDecode(data['students']!))
          : [],
    );
  }
}
