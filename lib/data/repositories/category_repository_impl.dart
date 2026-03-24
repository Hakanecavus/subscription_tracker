import 'package:subscription_tracker/core/errors/failures.dart';
import 'package:subscription_tracker/core/utils/result.dart';
import 'package:subscription_tracker/data/datasources/local/category_local_datasource.dart';
import 'package:subscription_tracker/data/models/category_model.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';
import 'package:subscription_tracker/domain/repositories/base_repository.dart';
import 'package:subscription_tracker/domain/repositories/category_repository.dart';

/// Implementation of CategoryRepository
class CategoryRepositoryImpl extends BaseRepository
    implements CategoryRepository {
  final CategoryLocalDataSource _localDataSource;

  CategoryRepositoryImpl({
    required CategoryLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<Result<List<Category>>> getAll() async {
    return executeLocalOperation(() async {
      final models = await _localDataSource.getAll();
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Result<Category?>> getById(String id) async {
    return executeLocalOperation(() async {
      final model = await _localDataSource.getById(id);
      return model?.toEntity();
    });
  }

  @override
  Future<Result<Category>> create(CreateCategoryParams params) async {
    return executeLocalOperation(() async {
      final model = CategoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: params.name,
        description: params.description,
        colorValue: params.colorValue,
        iconName: params.iconName,
        sortOrder: params.sortOrder ?? 0,
        createdAt: DateTime.now().toIso8601String(),
      );

      final result = await _localDataSource.insert(model);
      return result.toEntity();
    });
  }

  @override
  Future<Result<Category>> update(UpdateCategoryParams params) async {
    return executeLocalOperation(() async {
      final existing = await _localDataSource.getById(params.id);
      if (existing == null) {
        throw const CacheFailure(message: 'Category not found');
      }

      final updated = existing.copyWith(
        name: params.name,
        description: params.description,
        colorValue: params.colorValue,
        iconName: params.iconName,
        sortOrder: params.sortOrder,
      );

      final result = await _localDataSource.update(updated);
      return result.toEntity();
    });
  }

  @override
  Future<Result<void>> delete(String id) async {
    return executeLocalOperation(() async {
      final category = await _localDataSource.getById(id);
      if (category?.isDefault == 1) {
        throw const ValidationFailure(
          message: 'Cannot delete default categories',
        );
      }
      await _localDataSource.delete(id);
    });
  }

  @override
  Future<Result<List<Category>>> getDefaults() async {
    return executeLocalOperation(() async {
      final models = await _localDataSource.getDefaults();
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Result<List<Category>>> getCustom() async {
    return executeLocalOperation(() async {
      final models = await _localDataSource.getCustom();
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Result<void>> initializeDefaults() async {
    return executeLocalOperation(() async {
      await _localDataSource.initializeDefaults();
    });
  }

  @override
  Future<Result<Map<String, int>>> getSubscriptionCounts() async {
    return executeLocalOperation(() async {
      return await _localDataSource.getSubscriptionCounts();
    });
  }
}
