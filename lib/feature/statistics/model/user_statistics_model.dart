class UserStatisticsModel {
  final int testsCompleted;
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;

  UserStatisticsModel({
    required this.testsCompleted,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracy,
  });

  factory UserStatisticsModel.fromMap(Map<String, dynamic> map) {
    return UserStatisticsModel(
      testsCompleted: (map['testsCompleted'] ?? 0) is int 
          ? (map['testsCompleted'] ?? 0) as int
          : (map['testsCompleted'] ?? 0).toInt(),
      totalQuestions: (map['totalQuestions'] ?? 0) is int 
          ? (map['totalQuestions'] ?? 0) as int
          : (map['totalQuestions'] ?? 0).toInt(),
      correctAnswers: (map['correctAnswers'] ?? 0) is int 
          ? (map['correctAnswers'] ?? 0) as int
          : (map['correctAnswers'] ?? 0).toInt(),
      accuracy: (map['accuracy'] ?? 0.0) is double 
          ? (map['accuracy'] ?? 0.0) as double
          : (map['accuracy'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'testsCompleted': testsCompleted,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'accuracy': accuracy,
    };
  }

  @override
  String toString() {
    return 'UserStatisticsModel(testsCompleted: $testsCompleted, totalQuestions: $totalQuestions, correctAnswers: $correctAnswers, accuracy: $accuracy)';
  }
}
