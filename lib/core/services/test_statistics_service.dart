import 'package:aptimaster/feature/statistics/model/test_completion_model.dart';
import 'package:aptimaster/core/services/api_service.dart';
import 'package:aptimaster/core/services/api_endpoints.dart';

class TestStatisticsService {
  static TestStatisticsService? _instance;
  static TestStatisticsService get instance =>
      _instance ??= TestStatisticsService._();

  TestStatisticsService._();

  final ApiService _apiService = ApiService();

  // TODO: Get user ID from your authentication service or global state
  // This should be injected or obtained from a proper auth context
  String? _currentUserId;

  void setUserId(String userId) {
    _currentUserId = userId;
  }

  String? get userId => _currentUserId;

  // Save test completion to backend
  Future<bool> saveTestCompletion(
    TestCompletionModel testCompletion,
    String userId,
  ) async {
    try {
      if (_currentUserId == null && userId.isEmpty) {
        print('❌ No user ID found for saving test completion');
        return false;
      }

      final effectiveUserId = _currentUserId ?? userId;

      final response = await _apiService.post(
        ApiEndpoints.testCompletions,
        data: {
          ...testCompletion.toMap(),
          'userId': effectiveUserId,
          'submittedAt': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Test completion saved to backend successfully');

        // Update question type statistics
        await updateQuestionTypeStatistics(
          effectiveUserId,
          testCompletion.questionTypeStats,
        );

        return true;
      } else {
        print('❌ Failed to save test completion: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error saving test completion: $e');
      return false;
    }
  }

  // Update question type statistics on backend
  Future<bool> updateQuestionTypeStatistics(
    String userId,
    Map<String, Map<String, int>> questionTypeStats,
  ) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.questionTypeStatsByUser(userId),
        data: {
          'questionTypeStats': questionTypeStats,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Question type statistics updated on backend');
        return true;
      } else {
        print(
          '❌ Failed to update question type statistics: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      print('❌ Error updating question type statistics: $e');
      return false;
    }
  }

  // Get user's test completions
  Future<List<Map<String, dynamic>>> getTestCompletions(
    String userId, {
    int? limit,
  }) async {
    try {
      if (_currentUserId == null && userId.isEmpty) return [];

      final effectiveUserId = _currentUserId ?? userId;

      final response = await _apiService.get(
        ApiEndpoints.testCompletionsByUser(effectiveUserId),
        queryParameters: limit != null ? {'limit': limit} : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('❌ Failed to fetch test completions: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching test completions: $e');
      return [];
    }
  }

  // Get aggregated test statistics
  Future<Map<String, dynamic>> getUserTestStatistics(String userId) async {
    try {
      if (_currentUserId == null && userId.isEmpty) return {};

      final effectiveUserId = _currentUserId ?? userId;

      final response = await _apiService.get(
        ApiEndpoints.testStatisticsByUser(effectiveUserId),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        return data;
      } else {
        print('❌ Failed to fetch user test statistics: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('❌ Error fetching user test statistics: $e');
      return {};
    }
  }

  // Get question type performance data
  Future<List<Map<String, dynamic>>> getQuestionTypePerformance(
    String userId,
  ) async {
    try {
      if (_currentUserId == null && userId.isEmpty) return [];

      final effectiveUserId = _currentUserId ?? userId;

      final response = await _apiService.get(
        ApiEndpoints.questionTypeStatsByUser(effectiveUserId),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return List<Map<String, dynamic>>.from(data);
      } else {
        print(
          '❌ Failed to fetch question type performance: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print('❌ Error fetching question type performance: $e');
      return [];
    }
  }

  // Get daily progress data
  Future<List<Map<String, dynamic>>> getDailyProgress(
    String userId, {
    int days = 7,
  }) async {
    try {
      if (_currentUserId == null && userId.isEmpty) return [];

      final effectiveUserId = _currentUserId ?? userId;

      final response = await _apiService.get(
        ApiEndpoints.dailyProgressByUser(effectiveUserId),
        queryParameters: {'days': days},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('❌ Failed to fetch daily progress: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching daily progress: $e');
      return [];
    }
  }

  // Update profile with latest statistics
  Future<bool> updateUserProfileStatistics(String userId) async {
    try {
      if (_currentUserId == null && userId.isEmpty) return false;

      final effectiveUserId = _currentUserId ?? userId;

      // Get latest statistics
      final stats = await getUserTestStatistics(effectiveUserId);
      if (stats.isEmpty) return false;

      final response = await _apiService.put(
        '/users/$effectiveUserId/profile',
        data: {
          'testsTaken': stats['testsCompleted'] ?? 0,
          'questionsSolved': stats['totalQuestions'] ?? 0,
          'accuracy': stats['accuracy'] ?? 0.0,
          'lastStatsUpdate': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        print('✅ User profile statistics updated on backend');
        return true;
      } else {
        print('❌ Failed to update profile statistics: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating profile statistics: $e');
      return false;
    }
  }
}
