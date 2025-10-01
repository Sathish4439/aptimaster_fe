import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:aptimaster/core/services/storage_service.dart';
import 'package:aptimaster/core/services/test_statistics_service.dart';
import '../model/user_statistics_model.dart';
import '../model/question_type_performance_model.dart';
import '../model/daily_progress_model.dart';

class StatisticsController extends GetxController {
  static StatisticsController get to => Get.find();

  final StorageService _storageService = StorageService.instance;
  final TestStatisticsService _testStatsService =
      TestStatisticsService.instance;

  final RxBool _isLoading = false.obs;
  final Rx<UserStatisticsModel?> _overallStats = Rx<UserStatisticsModel?>(null);
  final RxList<QuestionTypePerformanceModel> _questionTypePerformance =
      <QuestionTypePerformanceModel>[].obs;
  final RxList<DailyProgressModel> _dailyProgress = <DailyProgressModel>[].obs;

  bool get isLoading => _isLoading.value;
  UserStatisticsModel? get overallStats => _overallStats.value;
  List<QuestionTypePerformanceModel> get questionTypePerformance =>
      _questionTypePerformance.value;
  List<DailyProgressModel> get dailyProgress => _dailyProgress.value;

  @override
  void onInit() {
    super.onInit();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      _isLoading.value = true;

      final userId = await _storageService.getUserId() ?? 'anonymous';

      // Load aggregated statistics from backend
      final aggregatedStats = await _testStatsService.getUserTestStatistics(
        userId,
      );

      // Set overall stats from backend data
      _overallStats.value = UserStatisticsModel.fromMap(aggregatedStats);

      // Load question type performance from backend
      await _loadQuestionTypePerformance(userId);

      // Load daily progress from backend
      await _loadDailyProgress(userId);
    } catch (e) {
      print('Error loading statistics: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadQuestionTypePerformance(String userId) async {
    try {
      // Load question type performance from backend
      final typePerformanceData = await _testStatsService
          .getQuestionTypePerformance(userId);

      _questionTypePerformance.value = typePerformanceData
          .map((data) => QuestionTypePerformanceModel.fromMap(data))
          .toList();

      print(
        '📊 Question type performance loaded from backend: ${typePerformanceData.length} categories',
      );

      // If no data available, show message
      if (typePerformanceData.isEmpty) {
        print(
          'ℹ️ No question type performance data available - user hasn\'t completed any tests yet',
        );
      }
    } catch (e) {
      print('Error loading question type performance: $e');
      _questionTypePerformance.value = [];
    }
  }

  Future<void> _loadDailyProgress(String userId) async {
    try {
      // Load daily progress from backend
      final dailyProgressData = await _testStatsService.getDailyProgress(
        userId,
      );

      _dailyProgress.value = dailyProgressData
          .map((data) => DailyProgressModel.fromMap(data))
          .toList();

      print(
        '📈 Daily progress data loaded from backend: ${dailyProgressData.length} days',
      );

      // If no data available, show message
      if (dailyProgressData.isEmpty) {
        print(
          'ℹ️ No daily progress data available - user hasn\'t completed any tests yet',
        );
      }
    } catch (e) {
      print('Error loading daily progress: $e');
      _dailyProgress.value = [];
    }
  }

  Future<void> refresh() async {
    await _loadStatistics();
  }

  // Get performance status for a category
  String getPerformanceStatus(double percentage) {
    if (percentage >= 80) return 'Excellent';
    if (percentage >= 70) return 'Good';
    if (percentage >= 60) return 'Average';
    return 'Needs Improvement';
  }

  // Get color for performance level
  Color getPerformanceColor(double percentage) {
    if (percentage >= 80) return const Color(0xFF4CAF50); // Green
    if (percentage >= 70) return const Color(0xFFFF9800); // Orange
    if (percentage >= 60) return const Color(0xFFFFC107); // Amber
    return const Color(0xFFF44336); // Red
  }

  @override
  void onClose() {
    // Clear all reactive data
    _overallStats.value = null;
    _questionTypePerformance.clear();
    _dailyProgress.clear();
    super.onClose();
  }
}
