import 'package:flutter/material.dart';

// UI State Model for Categories
// This model is used for UI state management and includes UI-specific properties
class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String slug;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? parentId;
  final int subcategoriesCount;
  final bool isExpanded;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.slug,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.parentId,
    required this.subcategoriesCount,
    this.isExpanded = false,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? slug,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? parentId,
    int? subcategoriesCount,
    bool? isExpanded,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      slug: slug ?? this.slug,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parentId: parentId ?? this.parentId,
      subcategoriesCount: subcategoriesCount ?? this.subcategoriesCount,
      isExpanded: isExpanded ?? this.isExpanded,
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
      'subcategoriesCount': subcategoriesCount,
      'isExpanded': isExpanded,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      slug: json['slug'] as String,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      parentId: json['parentId'] as String?,
      subcategoriesCount: json['_count']?['subcategories'] as int? ?? 0,
      isExpanded: json['isExpanded'] as bool? ?? false,
    );
  }

  // Helper methods for UI
  IconData get icon {
    switch (slug) {
      case 'arithmetic-aptitude':
        return Icons.calculate;
      case 'data-interpretation':
        return Icons.analytics;
      case 'verbal-ability':
        return Icons.psychology;
      case 'logical-reasoning':
        return Icons.lightbulb;
      case 'verbal-reasoning':
        return Icons.chat;
      case 'nonverbal-reasoning':
        return Icons.visibility;
      default:
        return Icons.category;
    }
  }

  Color get color {
    switch (slug) {
      case 'arithmetic-aptitude':
        return const Color(0xFF2196F3); // Blue
      case 'data-interpretation':
        return const Color(0xFF4CAF50); // Green
      case 'verbal-ability':
        return const Color(0xFF9C27B0); // Purple
      case 'logical-reasoning':
        return const Color(0xFFFF9800); // Orange
      case 'verbal-reasoning':
        return const Color(0xFF607D8B); // Blue Grey
      case 'nonverbal-reasoning':
        return const Color(0xFFE91E63); // Pink
      default:
        return const Color(0xFF757575); // Grey
    }
  }
}
