import 'package:aptimaster/core/services/api_endpoints.dart';
import 'package:aptimaster/core/services/ad_service.dart';
import 'package:aptimaster/core/utils/ad_manager.dart';
import 'package:aptimaster/feature/questions/model/qustion_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aptimaster/feature/questions/controller/question_controller.dart';
import 'package:aptimaster/core/widgets/app_text.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:aptimaster/core/models/discussion_models.dart';
import 'package:aptimaster/core/models/workspace_models.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';

class QuestionScreen extends StatefulWidget {
  final String subcategoryId;
  final String subcategoryName;
  final bool isLearningMode;

  const QuestionScreen({
    super.key,
    required this.subcategoryId,
    required this.subcategoryName,
    this.isLearningMode = false,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late QuestionModelController questionController;

  // Discussion state
  bool _showDiscussionPanel = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _queryController = TextEditingController();

  // Workspace state
  final TextEditingController _notesController = TextEditingController();
  final RxList<File> _uploadedImages = <File>[].obs;
  final ImagePicker _imagePicker = ImagePicker();
  bool _showWorkspacePanel = false;

  // Report state
  bool _showReportPanel = false;
  final TextEditingController _reportNameController = TextEditingController();
  final TextEditingController _reportEmailController = TextEditingController();
  final TextEditingController _reportPhoneController = TextEditingController();
  final TextEditingController _reportReasonController = TextEditingController();

  // Media state
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  final RxBool _isVideoInitialized = false.obs;
  final RxBool _isAudioPlaying = false.obs;
  String? _currentVideoUrl;

  // Timer state
  Timer? _timer;
  int _timeLeft = 0;
  bool _isTimerActive = false;

  @override
  void initState() {
    super.initState();
    questionController = Get.put(QuestionModelController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      questionController.loadQuestionModels(widget.subcategoryId);
    });
  }

  @override
  void dispose() {
    // Dispose all text controllers
    _nameController.dispose();
    _emailController.dispose();
    _queryController.dispose();
    _notesController.dispose();
    _reportNameController.dispose();
    _reportEmailController.dispose();
    _reportPhoneController.dispose();
    _reportReasonController.dispose();

    // Dispose media controllers
    _videoController?.dispose();
    _audioPlayer?.dispose();

    // Cancel timer
    _timer?.cancel();

    // Clear reactive lists
    _uploadedImages.clear();

    // Stop any ongoing media playback
    _stopMedia();

    // Dispose question controller
    questionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            AppText.h3(widget.subcategoryName),
            AppText.caption(
              widget.isLearningMode ? 'Learning Mode' : 'Test Mode',
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          Obx(() {
            final loading = questionController.isLoading;
            return loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => questionController.loadQuestionModels(
                      widget.subcategoryId,
                    ),
                  );
          }),
        ],
      ),
      body: Obx(() {
        final loading = questionController.isLoading;
        final hasError = questionController.errorMessage.isNotEmpty;
        final isEmpty = questionController.questions.isEmpty;
        final completed = questionController.isQuizComplete;

        if (loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (hasError) {
          return _buildErrorWidget();
        }

        if (isEmpty) {
          return _buildEmptyWidget();
        }

        if (completed) {
          print(
            '🎉 UI: QuizComplete detected, showing congratulations screen!',
          );
          return _buildQuizCompleteWidget();
        }

        return _buildQuestionContent();
      }),
    );
  }

  Widget _buildQuestionContent() {
    final question = questionController.currentQuestionModel!;

    // Start timer only in test mode and if question has time limit and media duration allows
    if (!widget.isLearningMode &&
        question.timeLimit != null &&
        !_isTimerActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTimerWithMediaCheck(question);
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Indicator
          _buildProgressIndicator(),
          const SizedBox(height: 20),

          // Question Section
          _buildQuestionSection(question),
          const SizedBox(height: 20),

          // Options Section
          _buildOptionsSection(question),
          const SizedBox(height: 20),

          // Submit Button
          if (!questionController.showExplanation) _buildSubmitButton(),

          // Explanation Section - only show in learning mode
          if (widget.isLearningMode && questionController.showExplanation)
            _buildExplanationSection(question),

          const SizedBox(height: 20),

          // Action Buttons Row
          _buildActionButtonsRow(),

          const SizedBox(height: 20),

          // Discussion Panel
          if (_showDiscussionPanel) _buildDiscussionPanel(),

          // Workspace Panel
          if (_showWorkspacePanel) _buildWorkspacePanel(),

          // Report Panel
          if (_showReportPanel) _buildReportPanel(),

          const SizedBox(height: 20),

          // Navigation Buttons
          _buildNavigationButtons(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = questionController.totalQuestionModels > 0
        ? (questionController.currentQuestionModelIndex + 1) /
              questionController.totalQuestionModels
        : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText.bodyMedium(
                  'Question ${questionController.currentQuestionModelIndex + 1} of ${questionController.totalQuestionModels}',
                ),
                Row(
                  children: [
                    if (questionController.currentQuestionModel?.timeLimit !=
                            null &&
                        !widget.isLearningMode)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _timeLeft <= 10
                              ? Theme.of(
                                  context,
                                ).colorScheme.error.withOpacity(0.1)
                              : Theme.of(
                                  context,
                                ).colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: AppText.caption(
                          'Time: ${_formatTime(_timeLeft)}',
                          color: _timeLeft <= 10
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    if (questionController.currentQuestionModel?.timeLimit !=
                        null)
                      const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: AppText.caption(
                        'Score: ${questionController.score}',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.outline.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionSection(QuestionModel question) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(
                      question.difficulty,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getDifficultyIcon(question.difficulty),
                        size: 16,
                        color: _getDifficultyColor(question.difficulty),
                      ),
                      const SizedBox(width: 4),
                      AppText.caption(
                        question.difficulty.toUpperCase(),
                        color: _getDifficultyColor(question.difficulty),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: AppText.caption(
                    '${question.points} pts',
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: AppText.caption(
                    '${question.mediaType}',
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Question Content
            AppText.h3(question.title),
            const SizedBox(height: 12),
            AppText.bodyLarge(question.content),

            // Media Content based on question type
            if (question.mediaUrl != null) ...[
              const SizedBox(height: 16),
              _buildMediaContent(question),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent(QuestionModel question) {
    final mediaUrl = question.mediaUrl!;
    final mediaType = question.mediaType;

    switch (mediaType) {
      case MediaType.IMAGE:
        return _buildImageWidget(mediaUrl);
      case MediaType.VIDEO:
        return _buildVideoWidget(mediaUrl);
      case MediaType.AUDIO:
        return _buildAudioWidget(mediaUrl);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildImageWidget(String imageUrl) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        //child: Image.asset(
        // 'images/image.jpg',
        child: Image.network(
          '${ApiEndpoints.imageUrl}/$imageUrl', // Using asset for testing
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Theme.of(
                context,
              ).colorScheme.errorContainer.withOpacity(0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 8),
                  AppText.bodyMedium(
                    'Image unavailable',
                    color: Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoWidget(String videoUrl) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Obx(() {
          // Initialize video if needed
          if (!_isVideoInitialized.value) {
            // _initializeVideo('video/video.mp4'); // Using asset for testing//

            _initializeVideo('${ApiEndpoints.imageUrl}/$videoUrl');
          }

          return _isVideoInitialized.value
              ? Stack(
                  children: [
                    VideoPlayer(_videoController!),
                    Positioned.fill(
                      child: Center(
                        child: IconButton(
                          onPressed: () {
                            if (_videoController!.value.isPlaying) {
                              _videoController!.pause();
                            } else {
                              _videoController!.play();
                            }
                          },
                          icon: Icon(
                            _videoController!.value.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            size: 64,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      AppText.bodyMedium('Loading video...'),
                    ],
                  ),
                );
        }),
      ),
    );
  }

  Widget _buildAudioWidget(String audioUrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.audiotrack,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodyMedium('Audio Content'),
                const SizedBox(height: 4),
                AppText.caption('Tap to play/pause'),
              ],
            ),
          ),
          Obx(
            () => IconButton(
              // onPressed: () => _toggleAudio('audio/audio.mp3'),
              onPressed: () => _toggleAudio(
                '${ApiEndpoints.imageUrl}/$audioUrl',
              ), // Using asset for testing
              icon: Icon(
                _isAudioPlaying.value ? Icons.pause_circle : Icons.play_circle,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeVideo(String videoUrl) async {
    try {
      // Only initialize if it's a new video URL
      if (_currentVideoUrl != videoUrl) {
        // Dispose previous controller
        await _videoController?.dispose();
        _isVideoInitialized.value = false;

        // Use asset controller for testing
        _videoController = VideoPlayerController.asset(videoUrl);
        await _videoController!.initialize();
        _currentVideoUrl = videoUrl;
        _isVideoInitialized.value = true;
      }
    } catch (e) {
      print('Error initializing video: $e');
      _isVideoInitialized.value = false;
    }
  }

  Future<void> _toggleAudio(String audioUrl) async {
    try {
      if (_audioPlayer == null) {
        _audioPlayer = AudioPlayer();
      }

      if (_isAudioPlaying.value) {
        await _audioPlayer!.pause();
        _isAudioPlaying.value = false;
      } else {
        await _audioPlayer!.play(
          AssetSource(audioUrl),
        ); // Using asset for testing
        _isAudioPlaying.value = true;
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Widget _buildOptionsSection(QuestionModel question) {
    // Check if it's an essay question
    if (question.questionType == QuestionType.ESSAY) {
      return _buildEssaySection(question);
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.h3('Choose your answer:'),
            const SizedBox(height: 16),
            ...question.options.map(
              (option) => _buildOptionCard(option, question),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEssaySection(QuestionModel question) {
    final showExplanation = questionController.showExplanation;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.h3('Write your essay:'),
            const SizedBox(height: 16),

            // Essay text field
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: questionController.essayTextController,
                maxLines: 8,
                maxLength: 2000, // Character limit
                onChanged: (text) {
                  questionController.updateEssayText(text);
                },
                enabled: !showExplanation,
                decoration: InputDecoration(
                  hintText: 'Type your essay here... (Maximum 2000 characters)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  counterStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

            const SizedBox(height: 12),

            // Word/Character count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Words: ${questionController.essayWordCount}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  'Characters: ${questionController.essayCharacterCount}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(OptionModel option, QuestionModel question) {
    final isSelected = questionController.selectedAnswer == option.id;
    final isCorrect = option.isCorrect;
    final showResult = questionController.showExplanation;

    Color? backgroundColor;
    Color? borderColor;
    Color? textColor;

    if (showResult) {
      if (isCorrect) {
        backgroundColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        textColor = Colors.green.shade700;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
        textColor = Colors.red.shade700;
      }
    } else if (isSelected) {
      backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
      borderColor = Theme.of(context).colorScheme.primary;
      textColor = Theme.of(context).colorScheme.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: showResult
            ? null
            : () => questionController.selectAnswer(option.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).colorScheme.surface,
            border: Border.all(
              color:
                  borderColor ??
                  Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: showResult
                      ? (isCorrect
                            ? Colors.green
                            : (isSelected ? Colors.red : Colors.grey))
                      : (isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey),
                ),
                child: Center(
                  child: showResult
                      ? Icon(
                          isCorrect
                              ? Icons.check
                              : (isSelected ? Icons.close : null),
                          color: Colors.white,
                          size: 18,
                        )
                      : Text(
                          String.fromCharCode(
                            65 + question.options.indexOf(option),
                          ),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppText.bodyMedium(
                  option.text,
                  color: textColor ?? Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canSubmitAnswer() {
    final question = questionController.currentQuestionModel;
    final isEssay = question?.questionType == QuestionType.ESSAY;

    if (isEssay) {
      return questionController.essayText?.trim().isNotEmpty ?? false;
    } else {
      return questionController.selectedAnswer != null;
    }
  }

  Widget _buildSubmitButton() {
    final question = questionController.currentQuestionModel;
    final isEssay = question?.questionType == QuestionType.ESSAY;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _canSubmitAnswer()
            ? () {
                if (!widget.isLearningMode) _stopTimer();
                _stopMedia();

                if (isEssay) {
                  questionController.submitEssayAnswer();
                } else {
                  questionController.submitAnswer();
                }

                // In test mode: Just show explanation, no auto-advance
                // User must click Next/Complete button manually
              }
            : null,
        icon: const Icon(Icons.check),
        label: AppText.button('Submit Answer'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildExplanationSection(QuestionModel question) {
    if (question.explanation == null || question.explanation!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                AppText.h3(
                  'Explanation',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppText.bodyMedium(question.explanation!),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonsRow() {
    // In learning mode, show discussion and workspace
    // In test mode, show only report
    if (widget.isLearningMode) {
      return Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.chat_bubble_outline,
              label: 'Discussion',
              onPressed: () =>
                  setState(() => _showDiscussionPanel = !_showDiscussionPanel),
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              icon: Icons.note_add_outlined,
              label: 'Workspace',
              onPressed: () =>
                  setState(() => _showWorkspacePanel = !_showWorkspacePanel),
              color: Colors.green,
            ),
          ),
        ],
      );
    } else {
      // Test mode - only show report
      return Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.report_problem_outlined,
              label: 'Report',
              onPressed: () =>
                  setState(() => _showReportPanel = !_showReportPanel),
              color: Colors.red,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: AppText.caption(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
      ),
    );
  }

  Widget _buildDiscussionPanel() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                AppText.h3('Discussion'),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => _showDiscussionPanel = false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Post Discussion Form
            _buildDiscussionForm(),
            const SizedBox(height: 20),

            // Discussion List
            _buildDiscussionList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscussionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bodyMedium('Post your comment:'),
        const SizedBox(height: 12),
        TextField(
          controller: _queryController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Your Comment',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _postDiscussion,
            child: AppText.button('Post Comment'),
          ),
        ),
      ],
    );
  }

  Widget _buildDiscussionList() {
    return Obx(() {
      if (questionController.isLoadingDiscussions) {
        return const Center(child: CircularProgressIndicator());
      }

      if (questionController.discussions.isEmpty) {
        return Center(
          child: Column(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 8),
              AppText.bodyMedium(
                'No discussions yet. Be the first to comment!',
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bodyMedium('Recent Discussions:'),
          const SizedBox(height: 12),
          ...questionController.discussions.map(
            (discussion) => _buildDiscussionItem(discussion),
          ),
        ],
      );
    });
  }

  Widget _buildDiscussionItem(DiscussionModel discussion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: discussion.userAvatar != null
                      ? NetworkImage(
                          '${ApiEndpoints.imageUrl}/${discussion.userAvatar}',
                        )
                      : null,
                  child: discussion.userAvatar == null
                      ? Icon(Icons.person, size: 16)
                      : null,
                ),
                const SizedBox(width: 8),
                AppText.caption(discussion.userName),
                const Spacer(),
                IconButton(
                  onPressed: () =>
                      questionController.toggleDiscussionLike(discussion.id),
                  icon: Icon(
                    discussion.isLiked
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                    color: discussion.isLiked
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                AppText.caption('${discussion.likes}'),
              ],
            ),
            const SizedBox(height: 8),
            AppText.bodyMedium(discussion.content),
            const SizedBox(height: 4),
            AppText.caption(
              '${_formatDateTime(discussion.createdAt)}',
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportPanel() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.report_problem_outlined, color: Colors.red),
                const SizedBox(width: 8),
                AppText.h3('Report Question'),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => _showReportPanel = false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _reportNameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reportEmailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reportPhoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reportReasonController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'What is the reason you missed this question?',
                hintText:
                    'Please provide a detailed explanation (minimum 10 characters)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: AppText.button('Submit Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: questionController.hasPreviousQuestionModel
                ? () {
                    if (!widget.isLearningMode) _stopTimer();
                    _stopMedia();
                    questionController.previousQuestionModel();
                  }
                : null,
            icon: const Icon(Icons.arrow_back),
            label: AppText.button('Previous'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              if (!widget.isLearningMode) _stopTimer();
              _stopMedia();

              if (questionController.hasNextQuestionModel) {
                // Normal next question behavior (only after explanation is shown)
                if (questionController.showExplanation) {
                  // Check if we should show interstitial ad
                  if (AdManager.shouldShowInterstitial()) {
                    Get.find<AdService>().showInterstitialAd(
                      onAdClosed: () {
                        questionController.nextQuestionModel();
                      },
                    );
                  } else {
                    questionController.nextQuestionModel();
                  }
                }
              } else {
                // Last question - auto-submit and show congratulations

                // Auto-submit answer if one is available but not yet submitted
                if (_canSubmitAnswer() && !questionController.showExplanation) {
                  final question = questionController.currentQuestionModel;
                  if (question?.questionType == QuestionType.ESSAY) {
                    questionController.submitEssayAnswer();
                  } else {
                    questionController.submitAnswer();
                  }
                }

                // Show congratulations with interstitial ad
                Get.find<AdService>().showInterstitialAd(
                  onAdClosed: () {
                    questionController.completeTest(widget.isLearningMode);
                  },
                );
              }
            },
            icon: const Icon(Icons.arrow_forward),
            label: AppText.button(
              questionController.hasNextQuestionModel ? 'Next' : 'Complete',
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            AppText.h3('Error Loading Questions'),
            const SizedBox(height: 8),
            AppText.bodyMedium(
              questionController.errorMessage,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  questionController.loadQuestionModels(widget.subcategoryId),
              icon: const Icon(Icons.refresh),
              label: AppText.button('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            AppText.h3('No Questions Available'),
            const SizedBox(height: 8),
            AppText.bodyMedium(
              'This subcategory doesn\'t have any questions yet.',
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  questionController.loadQuestionModels(widget.subcategoryId),
              icon: const Icon(Icons.refresh),
              label: AppText.button('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCompleteWidget() {
    final percentage = questionController.totalQuestionModels > 0
        ? (questionController.correctAnswers /
                  questionController.totalQuestionModels *
                  100)
              .round()
        : 0;

    // Call test completion tracking when the quiz completion widget is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      questionController.completeTest(widget.isLearningMode);
    });

    return _CongratulationScreen(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              AppText.h2('🎉 Congratulations!'),
              const SizedBox(height: 8),
              Text(
                'Test Completed Successfully!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              AppText.h3('Your Score: $percentage%'),
              const SizedBox(height: 8),
              AppText.bodyLarge(
                '${questionController.correctAnswers} out of ${questionController.totalQuestionModels} correct',
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(height: 8),
              AppText.bodyLarge(
                'Total Points: ${questionController.score}',
                color: Theme.of(context).colorScheme.primary,
              ),

              // Timing Analytics Card
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '⏱️ Test Analytics',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTimingStat(
                          context,
                          'Total Time',
                          questionController.formattedTestDuration,
                          Icons.timer,
                        ),
                        _buildTimingStat(
                          context,
                          'Avg/Question',
                          '${questionController.averageTimePerQuestion}s',
                          Icons.speed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Progress button with delay
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to profile to show progress
                  Get.toNamed('/profile');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.trending_up, size: 20),
                label: AppText.button('View Your Progress'),
              ),

              const SizedBox(height: 16),

              // Alternative navigation options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () => Get.offAllNamed('/home'),
                    icon: const Icon(Icons.home, size: 18),
                    label: AppText.caption('Home'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Get.toNamed('/statistics'),
                    icon: const Icon(Icons.analytics, size: 18),
                    label: AppText.caption('Statistics'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimingStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        AppText.caption(label),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Helper Methods

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getDifficultyIcon(String difficulty) {
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

  Widget _buildWorkspacePanel() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_add_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                AppText.h3('Workspace'),
              ],
            ),
            const SizedBox(height: 16),

            // Existing Workspace Data
            Obx(() {
              if (questionController.isLoadingWorkspace) {
                return const Center(child: CircularProgressIndicator());
              }

              if (questionController.workspaceData.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodyMedium('Your Previous Notes & Images:'),
                    const SizedBox(height: 8),
                    ...questionController.workspaceData.map(
                      (data) => _buildExistingWorkspaceItem(data),
                    ),
                    const SizedBox(height: 16),
                    const Divider(thickness: 1),
                    const SizedBox(height: 16),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            // Notes Section
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Add your notes',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Image Upload Section
            Obx(() {
              if (_uploadedImages.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodyMedium('Uploaded Images:'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _uploadedImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _uploadedImages[index],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.image,
                                              size: 40,
                                              color: Colors.grey,
                                            );
                                          },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      _uploadedImages.removeAt(index);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            // Add Image Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_photo_alternate),
                label: AppText.button('Add Image'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_notesController.text.isNotEmpty ||
                      _uploadedImages.isNotEmpty) {
                    await _saveWorkspaceData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: AppText.button('Save Workspace'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingWorkspaceItem(WorkspaceDataModel data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getDataTypeIcon(data.dataType),
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppText.bodyMedium(
                    data.title,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AppText.caption(
                          'Uploaded: ${_formatDate(data.createdAt)}',
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        AppText.caption(
                          _formatTimeFromDateTime(data.createdAt),
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _showDeleteConfirmation(data.id),
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (data.content.isNotEmpty) ...[
              AppText.bodySmall(data.content),
              const SizedBox(height: 8),
            ],
            if (data.mediaUrl != null) ...[
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    '${ApiEndpoints.imageUrl}/${data.mediaUrl}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.errorContainer.withOpacity(0.1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 32,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(height: 4),
                            AppText.caption(
                              'Image unavailable',
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getDataTypeIcon(DataType dataType) {
    switch (dataType) {
      case DataType.NOTE:
        return Icons.note;
      case DataType.IMAGE_HINT:
        return Icons.image;
      case DataType.FORMULA:
        return Icons.functions;
      case DataType.TIP:
        return Icons.lightbulb;
      case DataType.SOLUTION:
        return Icons.check_circle;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        _uploadedImages.add(File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText.bodyMedium('Error picking image: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _saveWorkspaceData() async {
    try {
      // Save notes if any
      if (_notesController.text.isNotEmpty) {
        final success = await questionController.createWorkspaceData(
          title: 'Notes',
          content: _notesController.text,
          dataType: DataType.NOTE,
          isPublic: false,
        );

        if (success) {
          _notesController.clear();
        }
      }

      // Save images if any
      for (final imageFile in _uploadedImages) {
        final success = await questionController.createWorkspaceData(
          title: 'Image Hint',
          content: 'User uploaded image hint',
          dataType: DataType.IMAGE_HINT,
          isPublic: false,
          imageFile: imageFile,
        );

        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText.bodyMedium('Failed to upload image'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          break;
        }
      }

      // Clear uploaded images after successful upload
      if (_uploadedImages.isNotEmpty) {
        _uploadedImages.clear();
        _notesController.clear();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText.bodyMedium('Workspace data saved successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText.bodyMedium('Error saving workspace data: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _postDiscussion() async {
    if (_queryController.text.trim().isNotEmpty) {
      final success = await questionController.createDiscussion(
        _queryController.text.trim(),
      );
      if (success) {
        _queryController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText.bodyMedium('Comment posted successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText.bodyMedium(
              'Failed to post comment. Please try again.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTimeFromDateTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showDeleteConfirmation(String workspaceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText.h3('Delete Workspace Item'),
        content: AppText.bodyMedium(
          'Are you sure you want to delete this workspace item? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText.button('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteWorkspaceItem(workspaceId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: AppText.button('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteWorkspaceItem(String workspaceId) async {
    try {
      final success = await questionController.deleteWorkspaceData(workspaceId);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText.bodyMedium('Workspace item deleted successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText.bodyMedium('Failed to delete workspace item'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText.bodyMedium('Error deleting workspace item: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _startTimerWithMediaCheck(QuestionModel question) async {
    _stopTimer();

    // Check if question has media and get its duration
    if (question.mediaUrl != null && question.mediaType != null) {
      int? mediaDuration;

      try {
        if (question.mediaType == MediaType.VIDEO && _videoController != null) {
          mediaDuration = _videoController!.value.duration.inSeconds;
        } else if (question.mediaType == MediaType.AUDIO) {
          // For audio, we'll use a default duration or get from metadata
          // Since audioplayers doesn't provide duration easily, we'll use a reasonable default
          mediaDuration = 300; // 5 minutes default for audio
        }

        // If media duration is longer than question time limit, don't start timer
        if (mediaDuration != null && mediaDuration > question.timeLimit!) {
          print(
            'Media duration ($mediaDuration seconds) is longer than question time limit (${question.timeLimit} seconds). Timer disabled.',
          );
          return;
        }
      } catch (e) {
        print('Error checking media duration: $e');
        // If we can't determine media duration, proceed with timer
      }
    }

    // Start timer if media duration allows or no media
    _startTimer(question.timeLimit!);
  }

  void _startTimer(int timeLimit) {
    _stopTimer();
    _timeLeft = timeLimit;
    _isTimerActive = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });

        // Show alert dialog when 30 seconds remaining
        if (_timeLeft == 30) {
          _showTimeWarningDialog();
        }
      } else {
        _stopTimer();
        _onTimeUp();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isTimerActive = false;
  }

  void _stopMedia() {
    // Stop video
    if (_videoController != null && _videoController!.value.isPlaying) {
      _videoController!.pause();
    }

    // Stop audio
    if (_audioPlayer != null && _isAudioPlaying.value) {
      _audioPlayer!.pause();
      _isAudioPlaying.value = false;
    }
  }

  void _showTimeWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: AppText.h3('Time Warning'),
        content: AppText.bodyMedium(
          'Only 30 seconds remaining! Please submit your answer soon.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: AppText.button('Continue'),
          ),
        ],
      ),
    );
  }

  void _onTimeUp() {
    // Only auto-advance in test mode
    if (!widget.isLearningMode) {
      // Stop media when time is up
      _stopMedia();

      // Auto-submit the current answer or show time up message
      if (questionController.selectedAnswer != null) {
        questionController.submitAnswer();
      } else {
        // Show time up snackbar instead of dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText.bodyMedium(
              'Time\'s up! Moving to next question...',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 2),
          ),
        );

        // Auto-advance to next question after a short delay, or show completion
        Future.delayed(const Duration(seconds: 2), () {
          print('🚀 Auto-advance check:');
          print(
            '   - Has next question: ${questionController.hasNextQuestionModel}',
          );
          print('   - Is learning mode: ${widget.isLearningMode}');

          if (questionController.hasNextQuestionModel) {
            print('   ➡️ Moving to next question');
            questionController.nextQuestionModel();
          } else {
            print('   ✅ Last question completed, calling completeTest()');
            // This is the last question, mark test as completed
            questionController.completeTest(widget.isLearningMode);
          }
        });
      }
    }
  }

  void _submitReport() async {
    if (_reportNameController.text.isNotEmpty &&
        _reportEmailController.text.isNotEmpty &&
        _reportPhoneController.text.isNotEmpty &&
        _reportReasonController.text.isNotEmpty) {
      if (_reportReasonController.text.trim().length < 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText.bodyMedium(
              'Please provide a detailed reason (minimum 10 characters)',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      try {
        final success = await questionController.submitReport(
          reason: _reportReasonController.text.trim(),
          description:
              'Name: ${_reportNameController.text}\nEmail: ${_reportEmailController.text}\nPhone: ${_reportPhoneController.text}',
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText.bodyMedium(
                'Report submitted successfully! Thank you for helping us improve.',
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          _reportNameController.clear();
          _reportEmailController.clear();
          _reportPhoneController.clear();
          _reportReasonController.clear();
          setState(() => _showReportPanel = false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText.bodyMedium(
                'Failed to submit report. Please try again.',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText.bodyMedium('Error submitting report: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText.bodyMedium('Please fill in all required fields'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

// Celebration Animation Widget
class _CongratulationScreen extends StatefulWidget {
  final Widget child;

  const _CongratulationScreen({required this.child});

  @override
  State<_CongratulationScreen> createState() => _CongratulationScreenState();
}

class _CongratulationScreenState extends State<_CongratulationScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.elasticOut),
    );

    // Start animations
    _showCelebration();
  }

  void _showCelebration() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
    _rotationController.forward();

    // Add confetti effect after animation
    await Future.delayed(const Duration(milliseconds: 1000));
    _showConfettiEffect();
  }

  void _showConfettiEffect() {
    // Simple fireworks effect
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => Container(
        color: Colors.transparent,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return AnimatedBuilder(
                animation: _scaleController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value + (index * 0.1),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.primaries[index],
                        shape: BoxShape.circle,
                      ),
                      margin: const EdgeInsets.all(2),
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ),
    );

    // Auto dismiss confetti
    Future.delayed(const Duration(milliseconds: 2000), () {
      Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 0.1,
            child: widget.child,
          ),
        );
      },
    );
  }
}
