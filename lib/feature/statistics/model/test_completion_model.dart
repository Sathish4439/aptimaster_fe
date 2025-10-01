class TestCompletionModel {
  final String id;
  final String? categoryId;
  final String? categoryName;
  final String subcategoryId;
  final String subcategoryName;
  final DateTime completedAt;
  final int totalQuestions;
  final int correctAnswers;
  final double scorePercentage;
  final int totalDuration; // Duration in seconds
  final Map<String, Map<String, int>>
  questionTypeStats; // {category: {'correct': 5, 'total': 8}}
  final Map<String, int?> questionTimings; // {questionId: seconds}

  TestCompletionModel({
    required this.id,
    this.categoryId,
    this.categoryName,
    required this.subcategoryId,
    required this.subcategoryName,
    required this.completedAt,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.scorePercentage,
    required this.totalDuration,
    required this.questionTypeStats,
    required this.questionTimings,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'subcategoryId': subcategoryId,
      'subcategoryName': subcategoryName,
      'completedAt': completedAt.toIso8601String(),
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'scorePercentage': scorePercentage,
      'totalDuration': totalDuration,
      'questionTypeStats': questionTypeStats,
      'questionTimings': questionTimings,
    };
  }

  factory TestCompletionModel.fromMap(Map<String, dynamic> map) {
    return TestCompletionModel(
      id: map['id'],
      categoryId: map['categoryId'],
      categoryName: map['categoryName'],
      subcategoryId: map['subcategoryId'],
      subcategoryName: map['subcategoryName'],
      completedAt: DateTime.parse(map['completedAt']),
      totalQuestions: map['totalQuestions'],
      correctAnswers: map['correctAnswers'],
      scorePercentage: map['scorePercentage'].toDouble(),
      totalDuration: map['totalDuration'] ?? 0,
      questionTypeStats: Map<String, Map<String, int>>.from({
        for (var entry in (map['questionTypeStats'] ?? {}).entries)
          entry.key: Map<String, int>.from(entry.value),
      }),
      questionTimings: Map<String, int?>.from(map['questionTimings'] ?? {}),
    );
  }

  factory TestCompletionModel.createNew({
    String? categoryId,
    String? categoryName,
    required String subcategoryId,
    required String subcategoryName,
    required int totalQuestions,
    required int correctAnswers,
    required int totalDuration,
    required Map<String, Map<String, int>> questionTypeStats,
    required Map<String, int> questionTimings,
  }) {
    final now = DateTime.now();
    final scorePercentage = totalQuestions > 0
        ? (correctAnswers / totalQuestions * 100.0)
        : 0.0;

    return TestCompletionModel(
      id: 'test_${now.millisecondsSinceEpoch}',
      categoryId: categoryId,
      categoryName: categoryName,
      subcategoryId: subcategoryId,
      subcategoryName: subcategoryName,
      completedAt: now,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      scorePercentage: scorePercentage,
      totalDuration: totalDuration,
      questionTypeStats: questionTypeStats,
      questionTimings: questionTimings,
    );
  }
}
