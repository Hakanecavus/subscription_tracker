import 'package:subscription_tracker/core/utils/result.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';
import 'package:subscription_tracker/domain/usecases/base_usecase.dart';

/// Repository interface for category operations
abstract class CategoryRepository {
  /// Get all categories
  Future<Result<List<Category>>> getAll();

  /// Get category by ID
  Future<Result<Category?>> getById(String id);

  /// Create category
  Future<Result<Category>> create(CreateCategoryParams params);

  /// Update category
  Future<Result<Category>> update(UpdateCategoryParams params);

  /// Delete category
  Future<Result<void>> delete(String id);

  /// Get default categories
  Future<Result<List<Category>>> getDefaults();

  /// Get custom categories
  Future<Result<List<Category>>> getCustom();

  /// Initialize default categories
  Future<Result<void>> initializeDefaults();

  /// Get subscriptions count by category
  Future<Result<Map<String, int>>> getSubscriptionCounts();
}

/// Create category params
class CreateCategoryParams extends Params {
  final String name;
  final String? description;
  final int colorValue;
  final String? iconName;
  final int? sortOrder;

  const CreateCategoryParams({
    required this.name,
    this.description,
    required this.colorValue,
    this.iconName,
    this.sortOrder,
  });
}

/// Update category params
class UpdateCategoryParams extends Params {
  final String id;
  final String? name;
  final String? description;
  final int? colorValue;
  final String? iconName;
  final int? sortOrder;

  const UpdateCategoryParams({
    required this.id,
    this.name,
    this.description,
    this.colorValue,
    this.iconName,
    this.sortOrder,
  });
}
