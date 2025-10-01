

import 'package:aptimaster/core/models/api_models.dart';

class OptionModel {
  final String id;
  final String text;
  final bool isCorrect;
  final int order;
  final DateTime createdAt;

  OptionModel({
    required this.id,
    required this.text,
    required this.isCorrect,
    required this.order,
    required this.createdAt,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: json['id'],
      text: json['text'],
      isCorrect: json['isCorrect'],
      order: json['order'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isCorrect': isCorrect,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

enum QuestionType {
  MULTIPLE_CHOICE,
  FILL_IN_BLANK,
  TRUE_FALSE,
  ESSAY,
  IMAGE_BASED,
  VIDEO_BASED,
  AUDIO_BASED,
}

enum MediaType { IMAGE, VIDEO, AUDIO, DOCUMENT }

class QuestionModel {
  final String id;
  final String title;
  final String content;
  final String difficulty;
  final int points;
  final int? timeLimit;
  final String? explanation;
  final QuestionType questionType;
  final String? mediaUrl;
  final MediaType? mediaType;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String categoryId;
  final AptitudeCategoryModel category;
  final List<OptionModel> options;

  QuestionModel({
    required this.id,
    required this.title,
    required this.content,
    required this.difficulty,
    required this.points,
    this.timeLimit,
    this.explanation,
    required this.questionType,
    this.mediaUrl,
    this.mediaType,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.categoryId,
    required this.category,
    required this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      difficulty: json['difficulty'],
      points: json['points'],
      timeLimit: json['timeLimit'],
      explanation: json['explanation'],
      questionType: QuestionType.values.firstWhere(
        (e) => e.name == json['questionType'],
        orElse: () => QuestionType.MULTIPLE_CHOICE,
      ),
      mediaUrl: json['mediaUrl'],
      mediaType: json['mediaType'] != null
          ? MediaType.values.firstWhere(
              (e) => e.name == json['mediaType'],
              orElse: () => MediaType.IMAGE,
            )
          : null,
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      categoryId: json['categoryId'],
      category: AptitudeCategoryModel.fromJson(json['category']),
      options: (json['options'] as List)
          .map((option) => OptionModel.fromJson(option))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'difficulty': difficulty,
      'points': points,
      'timeLimit': timeLimit,
      'explanation': explanation,
      'questionType': questionType.name,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType?.name,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'categoryId': categoryId,
      'category': category.toJson(),
      'options': options.map((option) => option.toJson()).toList(),
    };
  }
}
