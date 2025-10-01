import 'package:flutter/material.dart';

class OnboardingModel {
  final String title;
  final String description;
  final String imagePath;
  final IconData icon;
  final Color backgroundColor;
  final List<String> features;

  OnboardingModel({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.icon,
    required this.backgroundColor,
    required this.features,
  });
}

class OnboardingData {
  static List<OnboardingModel> getPages() {
    return [
      OnboardingModel(
        title: "Master Technical Interviews",
        description:
            "Prepare for coding interviews with our comprehensive collection of programming questions, algorithms, and data structures.",
        imagePath: "assets/images/coding_interview.png",
        icon: Icons.code,
        backgroundColor: const Color(0xFF2196F3),
        features: [
          "500+ Coding Problems",
          "Multiple Programming Languages",
          "Step-by-step Solutions",
          "Time Complexity Analysis",
        ],
      ),
      OnboardingModel(
        title: "Ace Aptitude Tests",
        description:
            "Sharpen your logical reasoning, quantitative aptitude, and verbal ability with thousands of practice questions.",
        imagePath: "assets/images/aptitude_test.png",
        icon: Icons.psychology,
        backgroundColor: const Color(0xFF4CAF50),
        features: [
          "Quantitative Aptitude",
          "Logical Reasoning",
          "Verbal Ability",
          "Mock Tests Available",
        ],
      ),
      OnboardingModel(
        title: "System Design Mastery",
        description:
            "Learn to design scalable systems and ace system design interviews with our structured approach and real-world examples.",
        imagePath: "assets/images/system_design.png",
        icon: Icons.architecture,
        backgroundColor: const Color(0xFFFF9800),
        features: [
          "Scalability Patterns",
          "Database Design",
          "Load Balancing",
          "Real-world Case Studies",
        ],
      ),
      OnboardingModel(
        title: "Behavioral Interview Prep",
        description:
            "Master behavioral questions with our STAR method framework and practice with common interview scenarios.",
        imagePath: "assets/images/behavioral_interview.png",
        icon: Icons.people,
        backgroundColor: const Color(0xFF9C27B0),
        features: [
          "STAR Method Framework",
          "Common Scenarios",
          "Leadership Examples",
          "Teamwork Stories",
        ],
      ),
      OnboardingModel(
        title: "Track Your Progress",
        description:
            "Monitor your improvement with detailed analytics, performance tracking, and personalized study recommendations.",
        imagePath: "assets/images/progress_tracking.png",
        icon: Icons.analytics,
        backgroundColor: const Color(0xFF03DAC6),
        features: [
          "Performance Analytics",
          "Weakness Identification",
          "Study Recommendations",
          "Achievement Badges",
        ],
      ),
    ];
  }
}
