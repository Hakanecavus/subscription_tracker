import 'package:subscription_tracker/core/errors/failures.dart';
import 'package:subscription_tracker/core/utils/result.dart';
import 'package:subscription_tracker/data/datasources/local/subscription_local_datasource.dart';
import 'package:subscription_tracker/data/models/subscription_model.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';
import 'package:subscription_tracker/domain/repositories/base_repository.dart';
import 'package:subscription_tracker/domain/repositories/subscription_repository.dart';

/// Implementation of SubscriptionRepository
class SubscriptionRepositoryImpl extends BaseRepository
    implements SubscriptionRepository {
  final SubscriptionLocalDataSource _localDataSource;

  SubscriptionRepositoryImpl({
    required SubscriptionLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<Result<List<Subscription>>> getAll() async {
    return executeLocalOperation(() async {
      final models = await _localDataSource.getAll();
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Result<List<Subscription>>> getActive() async {
    return executeLocalOperation(() async {
      final models = await _localDataSource.getActive();
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Result<Subscription?>> getById(String id) async {
    return executeLocalOperation(() async {
      final model = await _localDataSource.getById(id);
      return model?.toEntity();
    });
  }

  @override
  Future<Result<List<Subscription>>> getByCategory(String categoryId) async {
    return executeLocalOperation(() async {
      final models = await _localDataSource.getByCategory(categoryId);
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Result<List<Subscription>>> getDueWithinDays(int days) async {
    return executeLocalOperation(() async {
      final models = await _localDataSource.getDueWithinDays(days);
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Result<double>> getTotalMonthlyCost() async {
    return executeLocalOperation(() async {
      return await _localDataSource.getTotalMonthlyCost();
    });
  }

  @override
  Future<Result<double>> getTotalYearlyCost() async {
    return executeLocalOperation(() async {
      return await _localDataSource.getTotalYearlyCost();
    });
  }

  @override
  Future<Result<Subscription>> create(CreateSubscriptionParams params) async {
    return executeLocalOperation(() async {
      final now = DateTime.now();
      final model = SubscriptionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: params.name,
        description: params.description,
        amount: params.amount,
        currency: params.currency,
        billingCycle: params.billingCycle.name,
        startDate: params.startDate.toIso8601String(),
        endDate: params.endDate?.toIso8601String(),
        nextBillingDate: params.nextBillingDate.toIso8601String(),
        categoryId: params.categoryId,
        iconUrl: params.iconUrl,
        websiteUrl: params.websiteUrl,
        paymentMethod: params.paymentMethod.name,
        hasReminder: params.hasReminder ? 1 : 0,
        reminderDays: params.reminderDays?.join(','),
        notes: params.notes,
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      );

      final result = await _localDataSource.insert(model);
      return result.toEntity();
    });
  }

  @override
  Future<Result<Subscription>> update(UpdateSubscriptionParams params) async {
    return executeLocalOperation(() async {
      final existing = await _localDataSource.getById(params.id);
      if (existing == null) {
        throw const CacheFailure(message: 'Subscription not found');
      }

      final updated = existing.copyWith(
        name: params.name,
        description: params.description,
        amount: params.amount,
        currency: params.currency,
        billingCycle: params.billingCycle?.name,
        endDate: params.endDate?.toIso8601String(),
        nextBillingDate: params.nextBillingDate?.toIso8601String(),
        categoryId: params.categoryId,
        iconUrl: params.iconUrl,
        websiteUrl: params.websiteUrl,
        paymentMethod: params.paymentMethod?.name,
        isActive: params.isActive != null ? (params.isActive! ? 1 : 0) : null,
        hasReminder: params.hasReminder != null ? (params.hasReminder! ? 1 : 0) : null,
        reminderDays: params.reminderDays?.join(','),
        notes: params.notes,
        updatedAt: DateTime.now().toIso8601String(),
      );

      final result = await _localDataSource.update(updated);
      return result.toEntity();
    });
  }

  @override
  Future<Result<void>> delete(String id) async {
    return executeLocalOperation(() async {
      await _localDataSource.delete(id);
    });
  }

  @override
  Future<Result<Subscription>> toggleActive(String id) async {
    return executeLocalOperation(() async {
      final existing = await _localDataSource.getById(id);
      if (existing == null) {
        throw const CacheFailure(message: 'Subscription not found');
      }

      final updated = existing.copyWith(
        isActive: existing.isActive == 1 ? 0 : 1,
        updatedAt: DateTime.now().toIso8601String(),
      );

      final result = await _localDataSource.update(updated);
      return result.toEntity();
    });
  }

  @override
  Future<Result<Subscription>> updateBillingDate(String id, DateTime nextBillingDate) async {
    return executeLocalOperation(() async {
      final result = await _localDataSource.updateBillingDate(id, nextBillingDate);
      if (result == null) {
        throw const CacheFailure(message: 'Subscription not found');
      }
      return result.toEntity();
    });
  }

  @override
  Future<Result<List<Subscription>>> search(String query) async {
    return executeLocalOperation(() async {
      final models = await _localDataSource.search(query);
      return models.map((m) => m.toEntity()).toList();
    });
  }
}
