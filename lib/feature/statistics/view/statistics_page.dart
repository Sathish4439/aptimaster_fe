import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/banner_ad_widget.dart';
import '../controller/statistics_controller.dart';
import '../model/daily_progress_model.dart';
import '../model/question_type_performance_model.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final statisticsController = Get.put(StatisticsController());

    return Scaffold(
      appBar: AppBar(
        title: const AppText.h2('Statistics'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Obx(() {
        if (statisticsController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overall Performance Card
                    _buildOverallPerformanceCard(context, statisticsController),

                    const SizedBox(height: 24),

                    // Test Performance Pie Chart
                    AppText.h2('Test Performance Distribution'),
                    const SizedBox(height: 16),
                    _buildPieChart(context, statisticsController),

                    const SizedBox(height: 24),

                    // Category-wise Marks Analysis (Bar Chart)
                    AppText.h2('Marks by Category (Bar Chart)'),
                    const SizedBox(height: 16),
                    _buildCategoryMarksChart(context, statisticsController),

                    const SizedBox(height: 24),

                    // Question Type Performance (Pie Chart)
                    AppText.h2('Performance by Question Type (Pie Chart)'),
                    const SizedBox(height: 16),
                    _buildQuestionTypePieChart(context, statisticsController),

                    const SizedBox(height: 24),

                    // Question Type Performance (Bar Chart)
                    AppText.h2('Performance by Question Type (Bar Chart)'),
                    const SizedBox(height: 16),
                    _buildQuestionTypeChart(context, statisticsController),

                    const SizedBox(height: 24),

                    // Daily Progress Line Chart
                    AppText.h2('Daily Progress Trend'),
                    const SizedBox(height: 16),
                    _buildLineChart(context, statisticsController),

                    const SizedBox(height: 24),

                    // Detailed Test Analysis
                    AppText.h2('Detailed Test Analysis'),
                    const SizedBox(height: 16),
                    _buildDetailedTestAnalysis(context, statisticsController),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Banner Ad at bottom
            const BannerAdContainer(pageId: 'statistics'),
          ],
        );
      }),
    );
  }

  Widget _buildOverallPerformanceCard(
    BuildContext context,
    StatisticsController controller,
  ) {
    return Obx(() {
      final overallStats = controller.overallStats;
      if (overallStats == null) {
        return const Card(child: Center(child: CircularProgressIndicator()));
      }

      final totalTests = overallStats.testsCompleted;
      final totalQuestions = overallStats.totalQuestions;
      final correctAnswers = overallStats.correctAnswers;
      final accuracy = overallStats.accuracy;

      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.h2('Overall Performance'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Tests Completed',
                      totalTests.toString(),
                      Icons.quiz,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Total Questions',
                      totalQuestions.toString(),
                      Icons.help_outline,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Correct Answers',
                      correctAnswers.toString(),
                      Icons.check_circle,
                      Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Accuracy',
                      '${accuracy.toStringAsFixed(1)}%',
                      Icons.trending_up,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          AppText.h3(value, color: color),
          const SizedBox(height: 4),
          AppText.caption(label),
        ],
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, StatisticsController controller) {
    return Obx(() {
      final overallStats = controller.overallStats;
      if (overallStats == null) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 300,
            child: const Center(child: CircularProgressIndicator()),
          ),
        );
      }

      final totalQuestions = overallStats.totalQuestions;
      final correctAnswers = overallStats.correctAnswers;
      final incorrectAnswers = totalQuestions - correctAnswers;

      if (totalQuestions == 0) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 300,
            child: const Center(
              child: AppText.bodyMedium('No test data available'),
            ),
          ),
        );
      }

      final correctPercentage = (correctAnswers / totalQuestions) * 100;
      final incorrectPercentage = (incorrectAnswers / totalQuestions) * 100;

      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          child: Column(
            children: [
              // Char
              Expanded(
                child: CustomPaint(
                  size: const Size(200, 200),
                  painter: PieChartPainter(
                    correctPercentage,
                    incorrectPercentage,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem('Correct', correctPercentage, Colors.green),
                  _buildLegendItem(
                    'Incorrect',
                    incorrectPercentage,
                    Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCategoryMarksChart(
    BuildContext context,
    StatisticsController controller,
  ) {
    // Mock data for category marks - replace with actual API data
    final categoryData = [
      {'category': 'Mathematics', 'totalMarks': 85.0, 'tests': 5},
      {'category': 'English', 'totalMarks': 72.0, 'tests': 4},
      {'category': 'Science', 'totalMarks': 90.0, 'tests': 6},
      {'category': 'General Knowledge', 'totalMarks': 68.0, 'tests': 3},
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 300,
        child: Column(
          children: [
            // Chart
            Expanded(
              child: CustomPaint(
                size: const Size(double.infinity, 200),
                painter: CategoryMarksChartPainter(categoryData),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Wrap(
              spacing: 16,
              children: categoryData.map((item) {
                final index = categoryData.indexOf(item);
                final colors = [
                  Colors.blue,
                  Colors.green,
                  Colors.orange,
                  Colors.purple,
                ];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: colors[index % colors.length],
                    ),
                    const SizedBox(width: 4),
                    AppText.caption(
                      '${item['category']}: ${item['totalMarks']} marks',
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionTypePieChart(
    BuildContext context,
    StatisticsController controller,
  ) {
    return Obx(() {
      final questionTypePerformance = controller.questionTypePerformance;

      if (questionTypePerformance.isEmpty) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 300,
            child: const Center(
              child: AppText.bodyMedium('No question type data available'),
            ),
          ),
        );
      }

      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          child: Column(
            children: [
              // Pie Chart
              Expanded(
                child: CustomPaint(
                  size: const Size(200, 200),
                  painter: QuestionTypePieChartPainter(questionTypePerformance),
                ),
              ),
              const SizedBox(height: 16),
              // Legend
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: questionTypePerformance.map((stats) {
                  final index = questionTypePerformance.indexOf(stats);
                  final colors = [
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.red,
                    Colors.teal,
                  ];
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: colors[index % colors.length],
                      ),
                      const SizedBox(width: 4),
                      AppText.caption(
                        '${stats.questionType}: ${stats.percentage.toStringAsFixed(1)}%',
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildQuestionTypeChart(
    BuildContext context,
    StatisticsController controller,
  ) {
    return Obx(() {
      final questionTypePerformance = controller.questionTypePerformance;

      if (questionTypePerformance.isEmpty) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 300,
            child: const Center(
              child: AppText.bodyMedium('No question type data available'),
            ),
          ),
        );
      }

      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          child: Column(
            children: [
              // Bar Chart
              Expanded(
                child: CustomPaint(
                  size: const Size(double.infinity, 200),
                  painter: QuestionTypeBarChartPainter(questionTypePerformance),
                ),
              ),
              const SizedBox(height: 16),
              // Legend
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: questionTypePerformance.map((stats) {
                  final index = questionTypePerformance.indexOf(stats);
                  final colors = [
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.red,
                    Colors.teal,
                  ];
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: colors[index % colors.length],
                      ),
                      const SizedBox(width: 4),
                      AppText.caption(
                        '${stats.questionType}: ${stats.percentage.toStringAsFixed(1)}%',
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLineChart(
    BuildContext context,
    StatisticsController controller,
  ) {
    return Obx(() {
      final dailyProgress = controller.dailyProgress;

      if (dailyProgress.isEmpty) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 300,
            child: const Center(
              child: AppText.bodyMedium('No daily progress data available'),
            ),
          ),
        );
      }

      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          child: CustomPaint(
            size: const Size(double.infinity, 260),
            painter: LineChartPainter(dailyProgress),
          ),
        ),
      );
    });
  }

  Widget _buildDetailedTestAnalysis(
    BuildContext context,
    StatisticsController controller,
  ) {
    // Mock data for detailed test analysis - replace with actual API data
    final testData = [
      {
        'testId': '1',
        'categoryName': 'Mathematics',
        'subcategoryName': 'Algebra',
        'scorePercentage': 85.0,
        'correctAnswers': 17,
        'totalQuestions': 20,
        'totalDuration': 1800, // 30 minutes
        'completedAt': DateTime.now().subtract(const Duration(days: 7)),
      },
      {
        'testId': '2',
        'categoryName': 'English',
        'subcategoryName': 'Grammar',
        'scorePercentage': 72.0,
        'correctAnswers': 14,
        'totalQuestions': 20,
        'totalDuration': 1500, // 25 minutes
        'completedAt': DateTime.now().subtract(const Duration(days: 5)),
      },
      {
        'testId': '3',
        'categoryName': 'Science',
        'subcategoryName': 'Physics',
        'scorePercentage': 90.0,
        'correctAnswers': 18,
        'totalQuestions': 20,
        'totalDuration': 2100, // 35 minutes
        'completedAt': DateTime.now().subtract(const Duration(days: 3)),
      },
      {
        'testId': '4',
        'categoryName': 'Mathematics',
        'subcategoryName': 'Geometry',
        'scorePercentage': 78.0,
        'correctAnswers': 16,
        'totalQuestions': 20,
        'totalDuration': 1650, // 27.5 minutes
        'completedAt': DateTime.now().subtract(const Duration(days: 1)),
      },
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test trend chart
            Container(
              height: 200,
              child: CustomPaint(
                size: const Size(double.infinity, 200),
                painter: DetailedTestAnalysisPainter(testData),
              ),
            ),
            const SizedBox(height: 20),
            // Test details list
            ...testData
                .map((test) => _buildTestDetailCard(context, test))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTestDetailCard(BuildContext context, Map<String, dynamic> test) {
    final date = test['completedAt'] as DateTime;
    final duration = Duration(seconds: test['totalDuration']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Test info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${test['categoryName']} - ${test['subcategoryName']}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                AppText.caption(
                  '${date.day}/${date.month}/${date.year}',
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ],
            ),
          ),
          // Score and stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText.h3(
                '${test['scorePercentage']}%',
                color: test['scorePercentage'] >= 80
                    ? Colors.green
                    : test['scorePercentage'] >= 60
                    ? Colors.orange
                    : Colors.red,
              ),
              AppText.caption(
                '${test['correctAnswers']}/${test['totalQuestions']} correct',
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              AppText.caption(
                '${duration.inMinutes}m ${duration.inSeconds % 60}s',
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, double percentage, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        AppText.caption('$label (${percentage.toStringAsFixed(1)}%)'),
      ],
    );
  }
}

class PieChartPainter extends CustomPainter {
  final double correctPercentage;
  final double incorrectPercentage;

  PieChartPainter(this.correctPercentage, this.incorrectPercentage);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    // Draw correct answers (green)
    final correctSweepAngle = (correctPercentage / 100) * 2 * math.pi;
    final correctPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      correctSweepAngle,
      true,
      correctPaint,
    );

    // Draw incorrect answers (red)
    final incorrectSweepAngle = (incorrectPercentage / 100) * 2 * math.pi;
    final incorrectPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + correctSweepAngle,
      incorrectSweepAngle,
      true,
      incorrectPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CategoryMarksChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> categoryData;

  CategoryMarksChartPainter(this.categoryData);

  @override
  void paint(Canvas canvas, Size size) {
    if (categoryData.isEmpty) return;

    final maxMarks = categoryData
        .map((e) => (e['totalMarks'] as num).toDouble())
        .reduce(math.max);

    if (maxMarks <= 0) return; // Prevent division by zero

    final barWidth = (size.width - 40) / categoryData.length;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    for (int i = 0; i < categoryData.length; i++) {
      final item = categoryData[i];
      final marks = (item['totalMarks'] as num).toDouble();
      final height = (marks / maxMarks) * (size.height - 60);

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      final x = 20 + (i * barWidth);
      final y = size.height - 40 - height;

      canvas.drawRect(Rect.fromLTWH(x, y, barWidth - 10, height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LineChartPainter extends CustomPainter {
  final List<DailyProgressModel> dailyProgress;

  LineChartPainter(this.dailyProgress);

  @override
  void paint(Canvas canvas, Size size) {
    if (dailyProgress.isEmpty || size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    // Horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = 20 + (i * (size.height - 40) / 4);
      if (y.isFinite) {
        canvas.drawLine(Offset(20, y), Offset(size.width - 20, y), gridPaint);
      }
    }

    // Vertical grid lines
    for (int i = 0; i <= 4; i++) {
      final x = 20 + (i * (size.width - 40) / 4);
      if (x.isFinite) {
        canvas.drawLine(Offset(x, 20), Offset(x, size.height - 20), gridPaint);
      }
    }

    // Draw line chart
    if (dailyProgress.length > 1) {
      for (int i = 0; i < dailyProgress.length - 1; i++) {
        final accuracy1 =
            dailyProgress[i].accuracy.isNaN ||
                !dailyProgress[i].accuracy.isFinite
            ? 0.0
            : dailyProgress[i].accuracy;
        final accuracy2 =
            dailyProgress[i + 1].accuracy.isNaN ||
                !dailyProgress[i + 1].accuracy.isFinite
            ? 0.0
            : dailyProgress[i + 1].accuracy;

        final x1 = 20 + (i / (dailyProgress.length - 1)) * (size.width - 40);
        final y1 = size.height - 20 - (accuracy1 / 100) * (size.height - 40);

        final x2 =
            20 + ((i + 1) / (dailyProgress.length - 1)) * (size.width - 40);
        final y2 = size.height - 20 - (accuracy2 / 100) * (size.height - 40);

        // Check for valid coordinates
        if (x1.isFinite && y1.isFinite && x2.isFinite && y2.isFinite) {
          canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
          canvas.drawCircle(Offset(x1, y1), 3, pointPaint);
        }
      }
    }

    // Draw last point
    if (dailyProgress.isNotEmpty) {
      final lastIndex = dailyProgress.length - 1;
      final lastAccuracy =
          dailyProgress[lastIndex].accuracy.isNaN ||
              !dailyProgress[lastIndex].accuracy.isFinite
          ? 0.0
          : dailyProgress[lastIndex].accuracy;
      final x =
          20 +
          (lastIndex / math.max(1, dailyProgress.length - 1)) *
              (size.width - 40);
      final y = size.height - 20 - (lastAccuracy / 100) * (size.height - 40);

      if (x.isFinite && y.isFinite) {
        canvas.drawCircle(Offset(x, y), 3, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class QuestionTypePieChartPainter extends CustomPainter {
  final List<QuestionTypePerformanceModel> questionTypeData;

  QuestionTypePieChartPainter(this.questionTypeData);

  @override
  void paint(Canvas canvas, Size size) {
    if (questionTypeData.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    double startAngle = -math.pi / 2; // Start from top

    for (int i = 0; i < questionTypeData.length; i++) {
      final data = questionTypeData[i];
      final sweepAngle = (data.percentage / 100) * 2 * math.pi;

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class QuestionTypeBarChartPainter extends CustomPainter {
  final List<QuestionTypePerformanceModel> questionTypeData;

  QuestionTypeBarChartPainter(this.questionTypeData);

  @override
  void paint(Canvas canvas, Size size) {
    if (questionTypeData.isEmpty) return;

    final maxPercentage = questionTypeData
        .map((e) => e.percentage)
        .reduce(math.max);

    if (maxPercentage <= 0) return;

    final barWidth = (size.width - 40) / questionTypeData.length;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    for (int i = 0; i < questionTypeData.length; i++) {
      final data = questionTypeData[i];
      final height = (data.percentage / maxPercentage) * (size.height - 60);

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      final x = 20 + (i * barWidth);
      final y = size.height - 40 - height;

      canvas.drawRect(Rect.fromLTWH(x, y, barWidth - 10, height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DetailedTestAnalysisPainter extends CustomPainter {
  final List<Map<String, dynamic>> testData;

  DetailedTestAnalysisPainter(this.testData);

  @override
  void paint(Canvas canvas, Size size) {
    if (testData.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // Draw accuracy trend line
    for (int i = 0; i < testData.length - 1; i++) {
      final score1 = (testData[i]['scorePercentage'] as num).toDouble();
      final score2 = (testData[i + 1]['scorePercentage'] as num).toDouble();

      final x1 = (i / (testData.length - 1)) * (size.width - 40) + 20;
      final y1 = size.height - 40 - (score1 / 100) * (size.height - 80);

      final x2 = ((i + 1) / (testData.length - 1)) * (size.width - 40) + 20;
      final y2 = size.height - 40 - (score2 / 100) * (size.height - 80);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      canvas.drawCircle(Offset(x1, y1), 3, pointPaint);
    }

    // Draw last point
    if (testData.isNotEmpty) {
      final lastIndex = testData.length - 1;
      final lastScore = (testData[lastIndex]['scorePercentage'] as num)
          .toDouble();
      final x = (lastIndex / (testData.length - 1)) * (size.width - 40) + 20;
      final y = size.height - 40 - (lastScore / 100) * (size.height - 80);
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
