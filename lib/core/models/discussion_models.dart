// Discussion Models
// These models represent discussion data for questions

class DiscussionModel {
  final String id;
  final String questionId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final int likes;
  final bool isLiked;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiscussionModel({
    required this.id,
    required this.questionId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.likes,
    required this.isLiked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DiscussionModel.fromJson(Map<String, dynamic> json) {
    return DiscussionModel(
      id: json['id'],
      questionId: json['questionId'],
      userId: json['userId'],
      userName: json['userName'] ?? json['user']?['name'] ?? 'Anonymous',
      userAvatar: json['userAvatar'] ?? json['user']?['avatar'],
      content: json['content'],
      likes: json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'likes': likes,
      'isLiked': isLiked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

