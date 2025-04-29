
class AssignmentData {
  final String dueDate;
  final String title;
  final String gameId;
  final String subjectId;
  final String assId;

  AssignmentData({
    required this.dueDate,
    required this.title,
    required this.gameId,
    required this.subjectId,
    required this.assId,
  });

  // Convert to cache format: Only serialize quiz fields if applicable
  Map<String, String> toCache() {
    final Map<String, String> cacheData = {
      'dueDate': dueDate,
      'subjectId': subjectId,
      'title': title,
      'gameId': gameId,
      'assignmentId': assId
    };

    return cacheData;
  }

  // Deserialize from cache
  factory AssignmentData.fromCache(Map<String, String> data) {
    return AssignmentData(
      title: data['title'] ?? '',
      subjectId: data['subjectId'] ?? '',
      gameId: data['gameId'] ?? '',
      dueDate: data['dueDate'] ?? '',
      assId: data['assignmentId'] ?? '',
    );
  }
}
