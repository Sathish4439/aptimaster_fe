class QuestionTypePerformanceModel {
  final String questionType;
  final int correct;
  final int total;
  final double percentage;

  QuestionTypePerformanceModel({
    required this.questionType,
    required this.correct,
    required this.total,
    required this.percentage,
  });

  factory QuestionTypePerformanceModel.fromMap(Map<String, dynamic> map) {
    final total = (map['total'] ?? 0) is int 
        ? (map['total'] ?? 0) as int
        : (map['total'] ?? 0).toInt();
    final correct = (map['correct'] ?? 0) is int 
        ? (map['correct'] ?? 0) as int
        : (map['correct'] ?? 0).toInt();
    
    return QuestionTypePerformanceModel(
      questionType: (map['questionType'] ?? 'Unknown') as String,
      correct: correct,
      total: total,
      percentage: total > 0 ? (correct / total) * 100 : 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionType': questionType,
      'correct': correct,
      'total': total,
      'percentage': percentage,
    };
  }

  @override
  String toString() {
    return 'QuestionTypePerformanceModel(questionType: $questionType, correct: $correct, total: $total, percentage: $percentage)';
  }
}
