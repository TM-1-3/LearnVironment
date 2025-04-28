
class AssignmentData {
  final String assignmentId;
  final String assignmentLogo;
  final String assignmentName;
  final String subjectId;

  AssignmentData({
    required this.assignmentId,
    required this.assignmentLogo,
    required this.assignmentName,
    required this.subjectId,
  });

  // Convert to cache format: Only serialize quiz fields if applicable
  Map<String, String> toCache() {
    final Map<String, String> cacheData = {
      'assignmentId': assignmentId,
      'subjectId': subjectId,
      'assignmentName': assignmentName,
      'assignmentLogo': assignmentLogo,
    };

    return cacheData;
  }

  // Deserialize from cache
  factory AssignmentData.fromCache(Map<String, String> data) {
    return AssignmentData(
      assignmentId: data['assignmentId'] ?? '',
      subjectId: data['subjectId'] ?? '',
      assignmentLogo: data['subjectLogo'] ?? '',
      assignmentName: data['subjectName'] ?? '',
    );
  }
}
