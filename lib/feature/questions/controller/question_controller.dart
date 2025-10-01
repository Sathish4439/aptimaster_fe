import 'package:aptimaster/feature/questions/model/qustion_model.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:aptimaster/core/models/workspace_models.dart';
import 'package:aptimaster/core/models/report_models.dart';
import 'package:aptimaster/core/models/discussion_models.dart';
import 'package:aptimaster/core/services/aptitude_repository.dart';
import 'package:aptimaster/core/services/storage_service.dart';
import 'package:aptimaster/core/services/test_statistics_service.dart';
import 'package:aptimaster/core/services/essay_service.dart';
import 'package:aptimaster/feature/statistics/model/test_completion_model.dart';
import 'dart:io';

class QuestionModelController extends GetxController {
  static QuestionModelController get to => Get.find();

  final AptitudeRepository _repository = AptitudeRepository();
  final StorageService _storageService = StorageService.instance;
  final TestStatisticsService _testStatsService =
      TestStatisticsService.instance;

  final RxList<QuestionModel> _questions = <QuestionModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxInt _currentQuestionModelIndex = 0.obs;
  final Rxn<String> _selectedAnswer = Rxn<String>();
  final RxBool _showExplanation = false.obs;
  final RxInt _score = 0.obs;
  final RxInt _correctAnswers = 0.obs;
  final RxInt _totalQuestionModels = 0.obs;

  // Workspace data
  final RxList<WorkspaceDataModel> _workspaceData = <WorkspaceDataModel>[].obs;
  final RxBool _isLoadingWorkspace = false.obs;
  final RxString _workspaceErrorMessage = ''.obs;

  // Reports data
  final RxList<QuestionReportModel> _reports = <QuestionReportModel>[].obs;
  final RxBool _isLoadingReports = false.obs;
  final RxString _reportsErrorMessage = ''.obs;

  // Discussions data
  final RxList<DiscussionModel> _discussions = <DiscussionModel>[].obs;
  final RxBool _isLoadingDiscussions = false.obs;
  final RxString _discussionsErrorMessage = ''.obs;

  // Current user ID
  final Rxn<String> _currentUserId = Rxn<String>();

  // Essay-related variables
  final TextEditingController essayTextController = TextEditingController();
  final Rxn<String> _essayText = Rxn<String>();
  final RxInt _essayWordCount = 0.obs;
  final RxInt _essayCharacterCount = 0.obs;

  // Getters
  List<QuestionModel> get questions => _questions;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  int get currentQuestionModelIndex => _currentQuestionModelIndex.value;
  String? get selectedAnswer => _selectedAnswer.value;
  bool get showExplanation => _showExplanation.value;
  int get score => _score.value;
  int get correctAnswers => _correctAnswers.value;
  int get totalQuestionModels => _totalQuestionModels.value;

  // Workspace getters
  List<WorkspaceDataModel> get workspaceData => _workspaceData;
  bool get isLoadingWorkspace => _isLoadingWorkspace.value;
  String get workspaceErrorMessage => _workspaceErrorMessage.value;

  // Reports getters
  List<QuestionReportModel> get reports => _reports;
  bool get isLoadingReports => _isLoadingReports.value;
  String get reportsErrorMessage => _reportsErrorMessage.value;

  // Discussions getters
  List<DiscussionModel> get discussions => _discussions;
  bool get isLoadingDiscussions => _isLoadingDiscussions.value;
  String get discussionsErrorMessage => _discussionsErrorMessage.value;

  // User getter
  String? get currentUserId => _currentUserId.value;

  // Essay getters
  String? get essayText => _essayText.value;
  int get essayWordCount => _essayWordCount.value;
  int get essayCharacterCount => _essayCharacterCount.value;

  QuestionModel? get currentQuestionModel {
    if (_questions.isEmpty ||
        _currentQuestionModelIndex.value >= _questions.length) {
      return null;
    }
    return _questions[_currentQuestionModelIndex.value];
  }

  bool get hasNextQuestionModel =>
      _currentQuestionModelIndex.value < _questions.length - 1;
  bool get hasPreviousQuestionModel => _currentQuestionModelIndex.value > 0;
  bool get isQuizComplete {
    return _currentQuestionModelIndex.value >= _questions.length ||
        _testCompleted.value;
  }

  // Test completion statistics (reactive to trigger UI updates)
  final RxBool _testCompleted = false.obs;

  // Current test session data
  String? _currentSubcategoryId;
  String? _currentSubcategoryName;
  Map<String, Map<String, int>> _questionTypeStats =
      {}; // {category: {'correct': 5, 'total': 8}}

  // Test timing data
  DateTime? _testStartTime;
  DateTime? _testEndTime;
  Map<String, int> _questionTimings = {}; // {questionId: seconds}
  DateTime? _currentQuestionStartTime;

  @override
  void onInit() {
    super.onInit();
    _resetQuiz();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final userId = await _storageService.getUserId();
      _currentUserId.value = userId;
    } catch (e) {}
  }

  void _resetQuiz() {
    _currentQuestionModelIndex.value = 0;
    _selectedAnswer.value = null;
    _showExplanation.value = false;
    _score.value = 0;
    _correctAnswers.value = 0;
    _totalQuestionModels.value = 0;

    // Clear essay data
    _clearEssayData();
  }

  Future<void> loadQuestionModels(
    String subcategoryId, {
    String? difficulty,
    int? limit,
  }) async {
    try {
      print(
        '🚀 QuestionModelController: Loading questions for subcategory: $subcategoryId',
      );
      _isLoading.value = true;
      _errorMessage.value = '';
      _resetQuiz();

      // Initialize subcategory data for tracking
      _currentSubcategoryId = subcategoryId;
      // TODO: Get subcategory name from repository or pass it as parameter
      _currentSubcategoryName =
          'Test Category'; // This should be populated with actual name
      _questionTypeStats.clear();

      // Initialize test timing
      _testStartTime = DateTime.now();
      _testEndTime = null;
      _questionTimings.clear();
      _currentQuestionStartTime = DateTime.now();

      final questions = await _repository.getQuestionModelsByCategory(
        subcategoryId,
        difficulty: difficulty,
        limit: limit,
      );

      _questions.value = questions;
      _totalQuestionModels.value = questions.length;

      if (questions.isEmpty) {
        _errorMessage.value = 'No questions available for this subcategory';
      } else {
        // Load data for the first question
        _loadCurrentQuestionData();
      }
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  void selectAnswer(String answerId) {
    _selectedAnswer.value = answerId;
  }

  void submitAnswer() {
    if (_selectedAnswer.value == null || currentQuestionModel == null) return;

    final correctOption = currentQuestionModel!.options.firstWhere(
      (option) => option.isCorrect,
      orElse: () => currentQuestionModel!.options.first,
    );

    final isCorrect = _selectedAnswer.value == correctOption.id;
    if (isCorrect) {
      _score.value += currentQuestionModel!.points;
      _correctAnswers.value++;
    }

    // Track question type statistics
    _trackQuestionTypeStats(isCorrect);

    // Track question timing
    _trackQuestionTiming();

    _showExplanation.value = true;
  }

  // Update essay text and counts
  void updateEssayText(String text) {
    _essayText.value = text;
    _essayCharacterCount.value = text.length;
    _essayWordCount.value = _calculateWordCount(text);
  }

  // Calculate word count
  int _calculateWordCount(String text) {
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
  }

  // Clear essay data
  void _clearEssayData() {
    _essayText.value = null;
    _essayWordCount.value = 0;
    _essayCharacterCount.value = 0;
    essayTextController.clear();
  }

  // Submit essay answer
  Future<void> submitEssayAnswer() async {
    if ((_essayText.value?.trim().isEmpty ?? true) ||
        currentQuestionModel == null) {
      return;
    }

    try {
      final userId = await _storageService.getUserId() ?? 'anonymous';

      // Save essay answer to backend
      final success = await EssayService().saveEssayAnswer(
        questionId: currentQuestionModel!.id,
        userId: userId,
        answerText: _essayText.value!,
      );

      if (success) {
        // For essay questions, we don't have multiple choice scoring
        // So we'll mark it as "completed" and let manual review decide score
        _score.value +=
            currentQuestionModel!.points; // Award points for completion
        _correctAnswers.value++;
      } else {}

      // Track question timing
      _trackQuestionTiming();

      _showExplanation.value = true;
    } catch (e) {
      _showExplanation.value = true;
    }
  }

  void _trackQuestionTypeStats(bool isCorrect) {
    if (currentQuestionModel == null) return;

    // For now, we'll categorize by difficulty, but this could be enhanced
    // to use actual question type/category from the question model
    final category = _getQuestionCategory(currentQuestionModel!);

    if (!_questionTypeStats.containsKey(category)) {
      _questionTypeStats[category] = {'correct': 0, 'total': 0};
    }

    _questionTypeStats[category]!['total'] =
        (_questionTypeStats[category]!['total'] ?? 0) + 1;

    if (isCorrect) {
      _questionTypeStats[category]!['correct'] =
          (_questionTypeStats[category]!['correct'] ?? 0) + 1;
    }

    print(
      '📚 Question type stats updated: $category - ${isCorrect ? 'Correct' : 'Incorrect'}',
    );
  }

  void _trackQuestionTiming() {
    if (currentQuestionModel == null || _currentQuestionStartTime == null)
      return;

    final questionId = currentQuestionModel!.id;
    final timeSpent = DateTime.now()
        .difference(_currentQuestionStartTime!)
        .inSeconds;

    _questionTimings[questionId] = timeSpent;

    print(
      '⏱️ Question timing tracked: ${currentQuestionModel!.id} - ${timeSpent}s',
    );
  }

  void _startNextQuestionTimer() {
    _currentQuestionStartTime = DateTime.now();
  }

  int get testTotalDuration {
    if (_testStartTime == null) return 0;
    final endTime = _testEndTime ?? DateTime.now();
    return endTime.difference(_testStartTime!).inSeconds;
  }

  String get formattedTestDuration {
    final duration = testTotalDuration;
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  int get averageTimePerQuestion {
    if (_questionTimings.isEmpty) return 0;
    final totalTime = _questionTimings.values.reduce((sum, time) => sum + time);
    return totalTime ~/ _questionTimings.length;
  }

  String _getQuestionCategory(QuestionModel question) {
    // Analyze question to determine category
    // This is simplified - in a real implementation, you'd have better categorization
    final text = '${question.title} ${question.content} ${question.explanation}'
        .toLowerCase();

    if (text.contains('math') ||
        text.contains('number') ||
        text.contains('calculate')) {
      return 'Mathematics';
    } else if (text.contains('english') ||
        text.contains('grammar') ||
        text.contains('word')) {
      return 'English';
    } else if (text.contains('logic') ||
        text.contains('reason') ||
        text.contains('analyze')) {
      return 'Logic/Reasoning';
    } else if (text.contains('science') ||
        text.contains('physics') ||
        text.contains('chemistry')) {
      return 'Science';
    } else if (text.contains('history') ||
        text.contains('geography') ||
        text.contains('politics')) {
      return 'General Knowledge';
    } else {
      // Default category based on difficulty
      return question.difficulty;
    }
  }

  void goToQuestionModel(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentQuestionModelIndex.value = index;
      _selectedAnswer.value = null;
      _showExplanation.value = false;
      _loadCurrentQuestionData();
    }
  }

  void nextQuestionModel() {
    if (hasNextQuestionModel) {
      _currentQuestionModelIndex.value++;
      _selectedAnswer.value = null;
      _showExplanation.value = false;

      // Clear essay text
      _clearEssayData();

      // Start timer for next question
      _startNextQuestionTimer();

      _loadCurrentQuestionData();
    }
  }

  void previousQuestionModel() {
    if (hasPreviousQuestionModel) {
      _currentQuestionModelIndex.value--;
      _selectedAnswer.value = null;
      _showExplanation.value = false;

      // Clear essay text
      _clearEssayData();

      _loadCurrentQuestionData();
    }
  }

  Future<void> _loadCurrentQuestionData() async {
    final currentQuestion = currentQuestionModel;
    if (currentQuestion != null) {
      print('🔄 Loading data for question: ${currentQuestion.id}');
      await Future.wait([
        _loadWorkspaceData(currentQuestion.id),
        _loadReports(currentQuestion.id),
        _loadDiscussions(currentQuestion.id),
      ]);
      print('✅ Completed loading data for question: ${currentQuestion.id}');
    }
  }

  Future<void> _loadWorkspaceData(String questionId) async {
    try {
      _isLoadingWorkspace.value = true;
      _workspaceErrorMessage.value = '';

      final data = await _repository.getWorkspaceData(
        questionId,
        userId: _currentUserId.value,
        includePublic: true,
      );

      _workspaceData.value = data;
    } catch (e) {
      _workspaceErrorMessage.value = e.toString();
      print('Error loading workspace data: $e');
    } finally {
      _isLoadingWorkspace.value = false;
    }
  }

  Future<void> _loadReports(String questionId) async {
    try {
      _isLoadingReports.value = true;
      _reportsErrorMessage.value = '';

      final data = await _repository.getQuestionReports(questionId);
      _reports.value = data;
    } catch (e) {
      _reportsErrorMessage.value = e.toString();
      print('Error loading reports: $e');
    } finally {
      _isLoadingReports.value = false;
    }
  }

  Future<void> _loadDiscussions(String questionId) async {
    try {
      _isLoadingDiscussions.value = true;
      _discussionsErrorMessage.value = '';

      print('🔄 Loading discussions for question: $questionId');
      final data = await _repository.getQuestionDiscussions(questionId);
      _discussions.value = data;
      print('✅ Loaded ${data.length} discussions for question: $questionId');
    } catch (e) {
      _discussionsErrorMessage.value = e.toString();
      print('❌ Error loading discussions for question $questionId: $e');
    } finally {
      _isLoadingDiscussions.value = false;
    }
  }

  void toggleExplanation() {
    _showExplanation.value = !_showExplanation.value;
  }

  void restartQuiz() {
    _resetQuiz();
    _questions.clear();
    _workspaceData.clear();
    _reports.clear();
    _discussions.clear();
  }

  // Workspace methods
  Future<bool> createWorkspaceData({
    required String title,
    required String content,
    required DataType dataType,
    bool isPublic = false,
    File? imageFile,
  }) async {
    try {
      final currentQuestion = currentQuestionModel;
      final userId = _currentUserId.value;

      if (currentQuestion == null || userId == null) {
        return false;
      }

      await _repository.createWorkspaceData(
        questionId: currentQuestion.id,
        userId: userId,
        title: title,
        content: content,
        dataType: dataType,
        isPublic: isPublic,
        imageFile: imageFile,
      );

      // Reload workspace data
      await _loadWorkspaceData(currentQuestion.id);
      return true;
    } catch (e) {
      print('Error creating workspace data: $e');
      return false;
    }
  }

  Future<bool> updateWorkspaceData({
    required String id,
    String? title,
    String? content,
    DataType? dataType,
    bool? isPublic,
    File? imageFile,
  }) async {
    try {
      await _repository.updateWorkspaceData(
        id: id,
        title: title,
        content: content,
        dataType: dataType,
        isPublic: isPublic,
        imageFile: imageFile,
      );

      // Reload workspace data
      final currentQuestion = currentQuestionModel;
      if (currentQuestion != null) {
        await _loadWorkspaceData(currentQuestion.id);
      }
      return true;
    } catch (e) {
      print('Error updating workspace data: $e');
      return false;
    }
  }

  Future<bool> deleteWorkspaceData(String id) async {
    try {
      final userId = _currentUserId.value;
      if (userId == null) {
        print('Error: User ID not available for deletion');
        return false;
      }

      await _repository.deleteWorkspaceData(id, userId: userId);

      // Reload workspace data
      final currentQuestion = currentQuestionModel;
      if (currentQuestion != null) {
        await _loadWorkspaceData(currentQuestion.id);
      }
      return true;
    } catch (e) {
      print('Error deleting workspace data: $e');
      return false;
    }
  }

  // Reports methods
  Future<bool> submitReport({
    required String reason,
    String? description,
  }) async {
    try {
      final currentQuestion = currentQuestionModel;
      final userId = _currentUserId.value;

      if (currentQuestion == null || userId == null) {
        return false;
      }

      await _repository.submitReport(
        questionId: currentQuestion.id,
        userId: userId,
        reason: reason,
        description: description,
      );

      // Reload reports
      await _loadReports(currentQuestion.id);
      return true;
    } catch (e) {
      print('Error submitting report: $e');
      return false;
    }
  }

  // Discussion methods
  Future<bool> createDiscussion(String content) async {
    try {
      final currentQuestion = currentQuestionModel;
      final userId = _currentUserId.value;

      if (currentQuestion == null || userId == null) {
        print('❌ Cannot create discussion: missing question or user ID');
        return false;
      }

      print('🔄 Creating discussion for question: ${currentQuestion.id}');
      await _repository.createDiscussion(
        questionId: currentQuestion.id,
        userId: userId,
        content: content,
      );

      // Reload discussions
      await _loadDiscussions(currentQuestion.id);
      print('✅ Discussion created successfully');
      return true;
    } catch (e) {
      print('❌ Error creating discussion: $e');
      return false;
    }
  }

  Future<bool> toggleDiscussionLike(String discussionId) async {
    try {
      final userId = _currentUserId.value;
      final currentQuestion = currentQuestionModel;

      if (userId == null || currentQuestion == null) {
        print('❌ Cannot toggle like: missing user or question');
        return false;
      }

      final discussion = _discussions.firstWhere((d) => d.id == discussionId);

      print(
        '🔄 Toggling like for discussion: $discussionId (currently liked: ${discussion.isLiked})',
      );

      // Always use likeDiscussion - it now handles both like and unlike
      await _repository.likeDiscussion(
        discussionId: discussionId,
        userId: userId,
      );

      // Reload discussions to get updated like status
      await _loadDiscussions(currentQuestion.id);
      print('✅ Discussion like toggled successfully');
      return true;
    } catch (e) {
      print('❌ Error toggling discussion like: $e');
      return false;
    }
  }

  // Get difficulty color
  Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF4CAF50);
      case 'medium':
        return const Color(0xFFFF9800);
      case 'hard':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF757575);
    }
  }

  // Get difficulty icon
  IconData getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Icons.sentiment_satisfied;
      case 'medium':
        return Icons.sentiment_neutral;
      case 'hard':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }

  // Test completion tracking
  Future<void> completeTest(bool isLearningMode) async {
    try {
      // Prevent double counting if test already completed
      if (_testCompleted.value) return;

      // Only track statistics for test mode (not learning mode)
      if (isLearningMode) {
        _testCompleted.value = true;
        return;
      }

      // Mark test end time
      _testEndTime = DateTime.now();

      // Save detailed test completion data to backend
      if (_currentSubcategoryId != null && _currentSubcategoryName != null) {
        final testCompletion = TestCompletionModel.createNew(
          categoryId:
              _currentSubcategoryId, // Using subcategory as category for now
          categoryName: _currentSubcategoryName,
          subcategoryId: _currentSubcategoryId!,
          subcategoryName: _currentSubcategoryName!,
          totalQuestions: _totalQuestionModels.value,
          correctAnswers: _correctAnswers.value,
          totalDuration: testTotalDuration,
          questionTypeStats: _questionTypeStats,
          questionTimings: _questionTimings,
        );

        final userId = await _storageService.getUserId() ?? 'anonymous';
        final success = await _testStatsService.saveTestCompletion(
          testCompletion,
          userId,
        );

        if (success) {
          // Update user profile with latest statistics
          await _testStatsService.updateUserProfileStatistics(userId);

          print('✅ Test completion saved to backend successfully:');
          print('   - Subcategory: ${_currentSubcategoryName}');
          print('   - Questions: ${_totalQuestionModels.value}');
          print('   - Correct answers: ${_correctAnswers.value}');
          print(
            '   - Score: ${(_correctAnswers.value / _totalQuestionModels.value * 100).toStringAsFixed(2)}%',
          );
          print('   - Question types analyzed: ${_questionTypeStats.length}');
        } else {
          print('❌ Failed to save test completion to backend');
        }

        // Always mark test as completed to show congratulations screen
        _testCompleted.value = true;
        print('✅ _testCompleted set to true');
      } else {
        print('❌ Missing subcategory information for test completion');
        _testCompleted.value = true; // Still show congratulations screen
        print('✅ _testCompleted set to true (missing subcategory)');
      }
    } catch (e) {
      print('❌ Error updating test statistics: $e');
      // Even if there's an error, show congratulations screen
      _testCompleted.value = true;
      print('✅ _testCompleted set to true (exception case)');
    }
  }

  // Get current test statistics
  Future<Map<String, dynamic>> getCurrentTestStats() async {
    // Note: Test statistics are now fetched from backend API via TestStatisticsService
    return {
      'currentTestCorrect': _correctAnswers.value,
      'currentTestTotal': _totalQuestionModels.value,
      'currentTestScore': _score.value,
    };
  }

  @override
  void onClose() {
    // Clear all reactive data
    _questions.clear();
    _workspaceData.clear();
    _reports.clear();
    _discussions.clear();

    // Reset all state
    _resetQuiz();
    _testCompleted.value = false;

    // Clear essay controller
    essayTextController.dispose();

    super.onClose();
  }
}
