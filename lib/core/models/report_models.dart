// Report Models
// These models represent question reports and feedback

import 'workspace_models.dart';

enum ReportStatus { PENDING, REVIEWED, RESOLVED, REJECTED }

class QuestionReportModel {
  final String id;
  final String reason;
  final String? description;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String questionId;
  final String userId;
  final UserModel user;

  QuestionReportModel({
    required this.id,
    required this.reason,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.questionId,
    required this.userId,
    required this.user,
  });

  factory QuestionReportModel.fromJson(Map<String, dynamic> json) {
    return QuestionReportModel(
      id: json['id'],
      reason: json['reason'],
      description: json['description'],
      status: ReportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReportStatus.PENDING,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      questionId: json['questionId'],
      userId: json['userId'],
      user: UserModel.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reason': reason,
      'description': description,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'questionId': questionId,
      'userId': userId,
      'user': user.toJson(),
    };
  }
}
