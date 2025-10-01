import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:aptimaster/feature/onboarding/controller/onboarding_controller.dart';
import 'package:aptimaster/feature/onboarding/model/onboarding_model.dart';
import 'package:aptimaster/core/services/translation_service.dart';
import 'package:aptimaster/core/theme/app_colors.dart';

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({super.key});

  final OnboardingController controller = Get.put(OnboardingController());

  @override
  Widget build(BuildContext context) {
    final pages = OnboardingData.getPages();

    return Scaffold(
      body: IntroductionScreen(
        pages: pages.map((page) => _buildPageModel(page, context)).toList(),
        onDone: () => controller.completeOnboarding(),
        onSkip: () => controller.skipOnboarding(),
        showSkipButton: true,
        skip: Text(
          AppTranslations.translate('skip'),
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        next: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(
            Icons.arrow_forward,
            color: AppColors.white,
            size: 20,
          ),
        ),
        done: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            AppTranslations.translate('get_started'),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        dotsDecorator: DotsDecorator(
          size: const Size(10, 10),
          color: AppColors.border,
          activeSize: const Size(22, 10),
          activeColor: AppColors.primary,
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        globalBackgroundColor: AppColors.background,
        globalHeader: const SizedBox(height: 50),
        globalFooter: const SizedBox(height: 50),
      ),
    );
  }

  PageViewModel _buildPageModel(OnboardingModel page, BuildContext context) {
    return PageViewModel(
      title: page.title,
      body: page.description,
      image: _buildAnimatedImage(page),
      decoration: PageDecoration(
        titleTextStyle: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bodyTextStyle: TextStyle(
          fontSize: 16,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        imagePadding: const EdgeInsets.only(top: 40),
        pageColor: AppColors.background,
        bodyPadding: const EdgeInsets.symmetric(horizontal: 20),
        titlePadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
    );
  }

  Widget _buildAnimatedImage(OnboardingModel page) {
    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Background circle
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              page.backgroundColor.withOpacity(0.1),
                              page.backgroundColor.withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Main icon with animation
              Center(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1200),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              page.backgroundColor,
                              page.backgroundColor.withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: page.backgroundColor.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          page.icon,
                          size: 60,
                          color: AppColors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Floating feature badges
              ...page.features.asMap().entries.map((entry) {
                final index = entry.key;
                final feature = entry.value;
                return Positioned(
                  top: 50.0 + (index * 40.0),
                  right: 8,
                  child: TweenAnimationBuilder<double>(
                    duration: Duration(
                      milliseconds: 800 + (index * 200).toInt(),
                    ),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(30 * (1 - value), 0),
                        child: Opacity(
                          opacity: value,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth * 0.4,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadow,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getFeatureIcon(feature),
                                    size: 14,
                                    color: page.backgroundColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      feature,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  IconData _getFeatureIcon(String feature) {
    switch (feature) {
      case '500+ Coding Problems':
        return Icons.code;
      case 'Multiple Programming Languages':
        return Icons.language;
      case 'Step-by-step Solutions':
        return Icons.list_alt;
      case 'Time Complexity Analysis':
        return Icons.timer;
      case 'Quantitative Aptitude':
        return Icons.calculate;
      case 'Logical Reasoning':
        return Icons.psychology;
      case 'Verbal Ability':
        return Icons.chat;
      case 'Mock Tests Available':
        return Icons.quiz;
      case 'Scalability Patterns':
        return Icons.trending_up;
      case 'Database Design':
        return Icons.storage;
      case 'Load Balancing':
        return Icons.balance;
      case 'Real-world Case Studies':
        return Icons.assignment;
      case 'STAR Method Framework':
        return Icons.star;
      case 'Common Scenarios':
        return Icons.description;
      case 'Leadership Examples':
        return Icons.leaderboard;
      case 'Teamwork Stories':
        return Icons.group;
      case 'Performance Analytics':
        return Icons.analytics;
      case 'Weakness Identification':
        return Icons.bug_report;
      case 'Study Recommendations':
        return Icons.lightbulb;
      case 'Achievement Badges':
        return Icons.emoji_events;
      default:
        return Icons.check_circle;
    }
  }
}
