import 'dart:convert';

import 'package:subscription_tracker/domain/entities/subscription.dart';

/// Category model for data layer
class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final int colorValue;
  final String? iconName;
  final int isDefault;
  final int sortOrder;
  final String createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.colorValue,
    this.iconName,
    this.isDefault = 0,
    this.sortOrder = 0,
    required this.createdAt,
  });

  /// Convert from entity
  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      colorValue: entity.colorValue,
      iconName: entity.iconName,
      isDefault: entity.isDefault ? 1 : 0,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }

  /// Convert to entity
  Category toEntity() {
    return Category(
      id: id,
      name: name,
      description: description,
      colorValue: colorValue,
      iconName: iconName,
      isDefault: isDefault == 1,
      sortOrder: sortOrder,
      createdAt: DateTime.parse(createdAt),
    );
  }

  /// Convert from database map
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      colorValue: map['color_value'] as int,
      iconName: map['icon_name'] as String?,
      isDefault: map['is_default'] as int? ?? 0,
      sortOrder: map['sort_order'] as int? ?? 0,
      createdAt: map['created_at'] as String,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color_value': colorValue,
      'icon_name': iconName,
      'is_default': isDefault,
      'sort_order': sortOrder,
      'created_at': createdAt,
    };
  }

  /// Copy with method
  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    int? colorValue,
    String? iconName,
    int? isDefault,
    int? sortOrder,
    String? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
      iconName: iconName ?? this.iconName,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON
  String toJson() => jsonEncode(toMap());

  /// Convert from JSON
  factory CategoryModel.fromJson(String source) =>
      CategoryModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

/// Default categories data
class DefaultCategories {
  static List<CategoryModel> get all => [
    entertainment,
    productivity,
    utilities,
    health,
    finance,
    shopping,
    education,
    other,
  ];

  static const CategoryModel entertainment = CategoryModel(
    id: 'cat_entertainment',
    name: 'Entertainment',
    description: 'Streaming services, games, etc.',
    colorValue: 0xFFE91E63, // Pink
    iconName: 'movie',
    isDefault: 1,
    sortOrder: 0,
    createdAt: '',
  );

  static const CategoryModel productivity = CategoryModel(
    id: 'cat_productivity',
    name: 'Productivity',
    description: 'Work tools, cloud storage, etc.',
    colorValue: 0xFF2196F3, // Blue
    iconName: 'work',
    isDefault: 1,
    sortOrder: 1,
    createdAt: '',
  );

  static const CategoryModel utilities = CategoryModel(
    id: 'cat_utilities',
    name: 'Utilities',
    description: 'Phone, internet, electricity, etc.',
    colorValue: 0xFF9C27B0, // Purple
    iconName: 'bolt',
    isDefault: 1,
    sortOrder: 2,
    createdAt: '',
  );

  static const CategoryModel health = CategoryModel(
    id: 'cat_health',
    name: 'Health & Fitness',
    description: 'Gym, health apps, insurance, etc.',
    colorValue: 0xFF4CAF50, // Green
    iconName: 'favorite',
    isDefault: 1,
    sortOrder: 3,
    createdAt: '',
  );

  static const CategoryModel finance = CategoryModel(
    id: 'cat_finance',
    name: 'Finance',
    description: 'Banking, investments, etc.',
    colorValue: 0xFFFF9800, // Orange
    iconName: 'account_balance',
    isDefault: 1,
    sortOrder: 4,
    createdAt: '',
  );

  static const CategoryModel shopping = CategoryModel(
    id: 'cat_shopping',
    name: 'Shopping',
    description: 'Amazon Prime, memberships, etc.',
    colorValue: 0xFF00BCD4, // Cyan
    iconName: 'shopping_cart',
    isDefault: 1,
    sortOrder: 5,
    createdAt: '',
  );

  static const CategoryModel education = CategoryModel(
    id: 'cat_education',
    name: 'Education',
    description: 'Courses, learning platforms, etc.',
    colorValue: 0xFF795548, // Brown
    iconName: 'school',
    isDefault: 1,
    sortOrder: 6,
    createdAt: '',
  );

  static const CategoryModel other = CategoryModel(
    id: 'cat_other',
    name: 'Other',
    description: 'Miscellaneous subscriptions',
    colorValue: 0xFF607D8B, // Blue Grey
    iconName: 'category',
    isDefault: 1,
    sortOrder: 7,
    createdAt: '',
  );
}
