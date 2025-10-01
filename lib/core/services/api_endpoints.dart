import '../config/app_config.dart';

class ApiEndpoints {
  // Base URL is now managed by AppConfig
  static String get baseUrl => AppConfig.baseUrl;
  static String get imageUrl => AppConfig.imageUrl;

  // Categories endpoints
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';
  static String categorySubcategories(String id) =>
      '/categories/$id/subcategories';

  // Questions endpoints
  static const String questions = '/questions';
  static String questionById(String id) => '/questions/$id';
  static String questionsByCategory(String categoryId) =>
      '/questions/category/$categoryId';

  // Test Statistics endpoints
  static const String testCompletions = '/test-completions';
  static String testCompletionsByUser(String userId) =>
      '/users/$userId/test-completions';
  static String testStatisticsByUser(String userId) =>
      '/users/$userId/test-statistics';
  static String questionTypeStatsByUser(String userId) =>
      '/users/$userId/question-type-stats';
  static String dailyProgressByUser(String userId) =>
      '/users/$userId/daily-progress';

  // Essay endpoints
  static const String essays = '/essays';
  static String essayByQuestionAndUser(String questionId, String userId) =>
      '/essays/questions/$questionId/users/$userId';
  static String essaysByUser(String userId) => '/essays/users/$userId';

  // Helper methods for query parameters
  static String questionsWithFilters({
    String? categoryId,
    String? difficulty,
    int? limit,
  }) {
    final List<String> params = [];
    if (categoryId != null) params.add('categoryId=$categoryId');
    if (difficulty != null) params.add('difficulty=$difficulty');
    if (limit != null) params.add('limit=$limit');

    return params.isEmpty ? questions : '$questions?${params.join('&')}';
  }
}
