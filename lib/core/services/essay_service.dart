import '../models/essay_answer_model.dart';
import 'api_endpoints.dart';
import 'api_service.dart';

class EssayService {
  final ApiService _apiService = ApiService();

  // Save essay answer
  Future<bool> saveEssayAnswer({
    required String questionId,
    required String userId,
    required String answerText,
  }) async {
    try {
      print('📝 Saving essay answer for question: $questionId');

      final essayAnswer = EssayAnswerModel.createNew(
        questionId: questionId,
        userId: userId,
        answerText: answerText,
      );

      final response = await _apiService.post(
        ApiEndpoints.essays,
        data: essayAnswer.toMap(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Essay answer saved successfully');
        return true;
      } else {
        print('❌ Failed to save essay answer: Status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error saving essay answer: $e');
      return false;
    }
  }

  // Get essay answer for a specific question and user
  Future<EssayAnswerModel?> getEssayAnswer({
    required String questionId,
    required String userId,
  }) async {
    try {
      print('📖 Fetching essay answer for question: $questionId');

      final response = await _apiService.get(
        ApiEndpoints.essayByQuestionAndUser(questionId, userId),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['essayAnswer'] != null) {
          print('✅ Essay answer fetched successfully');
          return EssayAnswerModel.fromMap(data['essayAnswer']);
        }
      } else if (response.statusCode == 404) {
        print('ℹ️ No essay answer found for this question');
        return null;
      } else {
        print('❌ Failed to fetch essay answer: Status ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching essay answer: $e');
    }
    return null;
  }

  // Get all essay answers for a user
  Future<List<EssayAnswerModel>> getUserEssayAnswers(String userId) async {
    try {
      print('📚 Fetching all essay answers for user: $userId');

      final response = await _apiService.get(ApiEndpoints.essaysByUser(userId));

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['essayAnswers'] is List) {
          final essays = (data['essayAnswers'] as List)
              .map((e) => EssayAnswerModel.fromMap(e))
              .toList();

          print('✅ ${essays.length} essay answers fetched successfully');
          return essays;
        }
      } else {
        print(
          '❌ Failed to fetch user essay answers: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error fetching user essay answers: $e');
    }
    return [];
  }

  // Update existing essay answer
  Future<bool> updateEssayAnswer({
    required String essayAnswerId,
    required String answerText,
  }) async {
    try {
      print('🔄 Updating essay answer: $essayAnswerId');

      final updatedEssay = EssayAnswerModel(
        id: essayAnswerId,
        questionId: '', // Not needed for update
        userId: '', // Not needed for update
        answerText: answerText,
        wordCount: 0, // Will be calculated by backend
        characterCount: 0, // Will be calculated by backend
        submittedAt: DateTime.now(),
      );

      final response = await _apiService.put(
        '${ApiEndpoints.essays}/$essayAnswerId',
        data: updatedEssay.toMap(),
      );

      if (response.statusCode == 200) {
        print('✅ Essay answer updated successfully');
        return true;
      } else {
        print('❌ Failed to update essay answer: Status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating essay answer: $e');
      return false;
    }
  }

  // Calculate word count for text
  static int calculateWordCount(String text) {
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
  }

  // Calculate character计数
  static int calculateCharacterCount(String text) {
    return text.length;
  }
}
