class GameResultData {
  final String subjectId;
  final String studentId;
  final String gameId;
  final int correctCount;
  final int wrongCount;
  final DateTime timestamp;

  GameResultData({
    required this.subjectId,
    required this.studentId,
    required this.gameId,
    required this.correctCount,
    required this.wrongCount,
    required this.timestamp,
  });


  Map<String, dynamic> toCache() {
    return {
      'subjectId': subjectId,
      'studentId': studentId,
      'gameId': gameId,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
