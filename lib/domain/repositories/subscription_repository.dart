import 'package:subscription_tracker/core/utils/result.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';
import 'package:subscription_tracker/domain/usecases/base_usecase.dart';

/// Repository interface for subscription operations
abstract class SubscriptionRepository {
  /// Get all subscriptions
  Future<Result<List<Subscription>>> getAll();

  /// Get active subscriptions
  Future<Result<List<Subscription>>> getActive();

  /// Get subscription by ID
  Future<Result<Subscription?>> getById(String id);

  /// Get subscriptions by category
  Future<Result<List<Subscription>>> getByCategory(String categoryId);

  /// Get subscriptions due within days
  Future<Result<List<Subscription>>> getDueWithinDays(int days);

  /// Get total monthly cost
  Future<Result<double>> getTotalMonthlyCost();

  /// Get total yearly cost
  Future<Result<double>> getTotalYearlyCost();

  /// Create new subscription
  Future<Result<Subscription>> create(CreateSubscriptionParams params);

  /// Update subscription
  Future<Result<Subscription>> update(UpdateSubscriptionParams params);

  /// Delete subscription
  Future<Result<void>> delete(String id);

  /// Toggle subscription active status
  Future<Result<Subscription>> toggleActive(String id);

  /// Update next billing date
  Future<Result<Subscription>> updateBillingDate(String id, DateTime nextBillingDate);

  /// Search subscriptions
  Future<Result<List<Subscription>>> search(String query);
}

/// Create subscription params
class CreateSubscriptionParams extends Params {
  final String name;
  final String? description;
  final double amount;
  final String currency;
  final BillingCycle billingCycle;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextBillingDate;
  final String? categoryId;
  final String? iconUrl;
  final String? websiteUrl;
  final PaymentMethod paymentMethod;
  final bool hasReminder;
  final List<int>? reminderDays;
  final String? notes;

  const CreateSubscriptionParams({
    required this.name,
    this.description,
    required this.amount,
    required this.currency,
    required this.billingCycle,
    required this.startDate,
    this.endDate,
    required this.nextBillingDate,
    this.categoryId,
    this.iconUrl,
    this.websiteUrl,
    required this.paymentMethod,
    this.hasReminder = false,
    this.reminderDays,
    this.notes,
  });
}

/// Update subscription params
class UpdateSubscriptionParams extends Params {
  final String id;
  final String? name;
  final String? description;
  final double? amount;
  final String? currency;
  final BillingCycle? billingCycle;
  final DateTime? endDate;
  final DateTime? nextBillingDate;
  final String? categoryId;
  final String? iconUrl;
  final String? websiteUrl;
  final PaymentMethod? paymentMethod;
  final bool? isActive;
  final bool? hasReminder;
  final List<int>? reminderDays;
  final String? notes;

  const UpdateSubscriptionParams({
    required this.id,
    this.name,
    this.description,
    this.amount,
    this.currency,
    this.billingCycle,
    this.endDate,
    this.nextBillingDate,
    this.categoryId,
    this.iconUrl,
    this.websiteUrl,
    this.paymentMethod,
    this.isActive,
    this.hasReminder,
    this.reminderDays,
    this.notes,
  });
}
