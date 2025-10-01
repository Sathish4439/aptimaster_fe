// API Response Models
// These models represent data structures returned from the backend API

class SubcategoryModel {
  final String id;
  final String name;
  final String? description;
  final String slug;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String parentId;
  final int questionCount;

  SubcategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.slug,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.parentId,
    required this.questionCount,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      slug: json['slug'],
      imageUrl: json['imageUrl'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      parentId: json['parentId'],
      questionCount: json['_count']?['questions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'slug': slug,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'parentId': parentId,
      '_count': {'questions': questionCount},
    };
  }
}

class AptitudeCategoryModel {
  final String id;
  final String name;
  final String? description;
  final String slug;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? parentId;
  final AptitudeCategoryModel? parent;
  final List<AptitudeCategoryModel> subcategories;
  final int? questionCount;

  AptitudeCategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.slug,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.parentId,
    this.parent,
    required this.subcategories,
    this.questionCount,
  });

  factory AptitudeCategoryModel.fromJson(Map<String, dynamic> json) {
    return AptitudeCategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      slug: json['slug'],
      imageUrl: json['imageUrl'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      parentId: json['parentId'],
      parent: json['parent'] != null
          ? AptitudeCategoryModel.fromJson(json['parent'])
          : null,
      subcategories: json['subcategories'] != null
          ? (json['subcategories'] as List)
                .map((sub) => AptitudeCategoryModel.fromJson(sub))
                .toList()
          : [],
      questionCount: json['_count']?['questions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'slug': slug,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'parentId': parentId,
      'parent': parent?.toJson(),
      'subcategories': subcategories.map((sub) => sub.toJson()).toList(),
      '_count': {'questions': questionCount},
    };
  }
}
