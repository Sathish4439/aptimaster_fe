// Workspace Data Models
// These models represent workspace data (notes, hints, formulas) for questions

enum DataType { NOTE, IMAGE_HINT, FORMULA, TIP, SOLUTION }

class WorkspaceDataModel {
  final String id;
  final String title;
  final String content;
  final DataType dataType;
  final String? mediaUrl;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String questionId;
  final String userId;
  final UserModel user;

  WorkspaceDataModel({
    required this.id,
    required this.title,
    required this.content,
    required this.dataType,
    this.mediaUrl,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    required this.questionId,
    required this.userId,
    required this.user,
  });

  factory WorkspaceDataModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceDataModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      dataType: DataType.values.firstWhere(
        (e) => e.name == json['dataType'],
        orElse: () => DataType.NOTE,
      ),
      mediaUrl: json['mediaUrl'],
      isPublic: json['isPublic'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      questionId: json['questionId'] ?? '',
      userId: json['userId'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'dataType': dataType.name,
      'mediaUrl': mediaUrl,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'questionId': questionId,
      'userId': userId,
      'user': user.toJson(),
    };
  }
}

class UserModel {
  final String id;
  final String? name;
  final String? avatar;

  UserModel({required this.id, this.name, this.avatar});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'avatar': avatar};
  }
}
