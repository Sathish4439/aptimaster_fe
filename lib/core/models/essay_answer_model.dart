class EssayAnswerModel {
  final String id;
  final String questionId;
  final String userId;
  final String answerText;
  final int wordCount;
  final int characterCount;
  final DateTime submittedAt;

  EssayAnswerModel({
    required this.id,
    required this.questionId,
    required this.userId,
    required this.answerText,
    required this.wordCount,
    required this.characterCount,
    required this.submittedAt,
  });

  // Convert to JSON for API calls
  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'userId': userId,
      'answerText': answerText,
      'wordCount': wordCount,
      'characterCount': characterCount,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }

  // Create from JSON response
  factory EssayAnswerModel.fromMap(Map<String, dynamic> map) {
    return EssayAnswerModel(
      id: map['id'] ?? '',
      questionId: map['questionId'] ?? '',
      userId: map['userId'] ?? '',
      answerText: map['answerText'] ?? '',
      wordCount: map['wordCount'] ?? 0,
      characterCount: map['characterCount'] ?? 0,
      submittedAt:
          DateTime.tryParse(map['submittedAt'] ?? '') ?? DateTime.now(),
    );
  }

  // Create new essay answer for submission
  factory EssayAnswerModel.createNew({
    required String questionId,
    required String userId,
    required String answerText,
  }) {
    final trimmedText = answerText.trim();
    final wordCount = trimmedText
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
    final characterCount = answerText.length;

    return EssayAnswerModel(
      id: '', // Will be assigned by backend
      questionId: questionId,
      userId: userId,
      answerText: answerText,
      wordCount: wordCount,
      characterCount: characterCount,
      submittedAt: DateTime.now(),
    );
  }

  // Copy with updated text (for editing)
  EssayAnswerModel copyWith({String? answerText}) {
    final newText = answerText ?? this.answerText;
    final trimmedText = newText.trim();
    final wordCount = trimmedText
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
    final characterCount = newText.length;

    return EssayAnswerModel(
      id: id,
      questionId: questionId,
      userId: userId,
      answerText: newText,
      wordCount: wordCount,
      characterCount: characterCount,
      submittedAt: submittedAt,
    );
  }

  @override
  String toString() {
    return 'EssayAnswerModel(id: $id, questionId: $questionId, wordCount: $wordCount, characterCount: $characterCount)';
  }
}
