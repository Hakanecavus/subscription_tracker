import 'package:equatable/equatable.dart';

/// Base entity class
abstract class BaseEntity extends Equatable {
  const BaseEntity();
}

/// Subscription entity
class Subscription extends BaseEntity {
  final String id;
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
  final bool isActive;
  final bool hasReminder;
  final List<int>? reminderDays;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subscription({
    required this.id,
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
    this.isActive = true,
    this.hasReminder = false,
    this.reminderDays,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get monthly cost (normalized)
  double get monthlyCost {
    return switch (billingCycle) {
      BillingCycle.weekly => amount * 4.33,
      BillingCycle.biWeekly => amount * 2.17,
      BillingCycle.monthly => amount,
      BillingCycle.quarterly => amount / 3,
      BillingCycle.halfYearly => amount / 6,
      BillingCycle.yearly => amount / 12,
    };
  }

  /// Get yearly cost
  double get yearlyCost => monthlyCost * 12;

  /// Check if subscription is due soon (within 7 days)
  bool get isDueSoon {
    final daysUntil = nextBillingDate.difference(DateTime.now()).inDays;
    return daysUntil >= 0 && daysUntil <= 7;
  }

  /// Check if subscription is overdue
  bool get isOverdue => nextBillingDate.isBefore(DateTime.now());

  /// Check if subscription has ended
  bool get hasEnded => endDate?.isBefore(DateTime.now()) ?? false;

  /// Copy with method
  Subscription copyWith({
    String? id,
    String? name,
    String? description,
    double? amount,
    String? currency,
    BillingCycle? billingCycle,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextBillingDate,
    String? categoryId,
    String? iconUrl,
    String? websiteUrl,
    PaymentMethod? paymentMethod,
    bool? isActive,
    bool? hasReminder,
    List<int>? reminderDays,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      billingCycle: billingCycle ?? this.billingCycle,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      categoryId: categoryId ?? this.categoryId,
      iconUrl: iconUrl ?? this.iconUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isActive: isActive ?? this.isActive,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderDays: reminderDays ?? this.reminderDays,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    amount,
    currency,
    billingCycle,
    startDate,
    endDate,
    nextBillingDate,
    categoryId,
    iconUrl,
    websiteUrl,
    paymentMethod,
    isActive,
    hasReminder,
    reminderDays,
    notes,
    createdAt,
    updatedAt,
  ];
}

/// Category entity
class Category extends BaseEntity {
  final String id;
  final String name;
  final String? description;
  final int colorValue;
  final String? iconName;
  final bool isDefault;
  final int sortOrder;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    this.description,
    required this.colorValue,
    this.iconName,
    this.isDefault = false,
    this.sortOrder = 0,
    required this.createdAt,
  });

  Category copyWith({
    String? id,
    String? name,
    String? description,
    int? colorValue,
    String? iconName,
    bool? isDefault,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return Category(
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

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    colorValue,
    iconName,
    isDefault,
    sortOrder,
    createdAt,
  ];
}

/// Payment history entity
class PaymentHistory extends BaseEntity {
  final String id;
  final String subscriptionId;
  final DateTime paymentDate;
  final double amount;
  final String currency;
  final String? notes;
  final DateTime createdAt;

  const PaymentHistory({
    required this.id,
    required this.subscriptionId,
    required this.paymentDate,
    required this.amount,
    required this.currency,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    subscriptionId,
    paymentDate,
    amount,
    currency,
    notes,
    createdAt,
  ];
}

/// User preferences entity
class UserPreferences extends BaseEntity {
  final String? currencyCode;
  final String? languageCode;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final List<int> defaultReminderDays;
  final bool biometricEnabled;
  final String? lastBackupDate;
  final DateTime updatedAt;

  const UserPreferences({
    this.currencyCode,
    this.languageCode,
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.defaultReminderDays = const [1, 3, 7],
    this.biometricEnabled = false,
    this.lastBackupDate,
    required this.updatedAt,
  });

  UserPreferences copyWith({
    String? currencyCode,
    String? languageCode,
    bool? isDarkMode,
    bool? notificationsEnabled,
    List<int>? defaultReminderDays,
    bool? biometricEnabled,
    String? lastBackupDate,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      currencyCode: currencyCode ?? this.currencyCode,
      languageCode: languageCode ?? this.languageCode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultReminderDays: defaultReminderDays ?? this.defaultReminderDays,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    currencyCode,
    languageCode,
    isDarkMode,
    notificationsEnabled,
    defaultReminderDays,
    biometricEnabled,
    lastBackupDate,
    updatedAt,
  ];
}

/// Billing cycle enum
enum BillingCycle {
  weekly,
  biWeekly,
  monthly,
  quarterly,
  halfYearly,
  yearly,
}

/// Billing cycle extension
extension BillingCycleExtension on BillingCycle {
  String get displayName {
    return switch (this) {
      BillingCycle.weekly => 'Weekly',
      BillingCycle.biWeekly => 'Bi-weekly',
      BillingCycle.monthly => 'Monthly',
      BillingCycle.quarterly => 'Quarterly',
      BillingCycle.halfYearly => 'Half-yearly',
      BillingCycle.yearly => 'Yearly',
    };
  }

  int get daysInterval {
    return switch (this) {
      BillingCycle.weekly => 7,
      BillingCycle.biWeekly => 14,
      BillingCycle.monthly => 30,
      BillingCycle.quarterly => 91,
      BillingCycle.halfYearly => 183,
      BillingCycle.yearly => 365,
    };
  }

  DateTime calculateNextBillingDate(DateTime from) {
    return switch (this) {
      BillingCycle.weekly => from.add(const Duration(days: 7)),
      BillingCycle.biWeekly => from.add(const Duration(days: 14)),
      BillingCycle.monthly => DateTime(from.year, from.month + 1, from.day),
      BillingCycle.quarterly => DateTime(from.year, from.month + 3, from.day),
      BillingCycle.halfYearly => DateTime(from.year, from.month + 6, from.day),
      BillingCycle.yearly => DateTime(from.year + 1, from.month, from.day),
    };
  }
}

/// Payment method enum
enum PaymentMethod {
  creditCard,
  debitCard,
  bankTransfer,
  paypal,
  googlePay,
  applePay,
  crypto,
  other,
}

/// Payment method extension
extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    return switch (this) {
      PaymentMethod.creditCard => 'Credit Card',
      PaymentMethod.debitCard => 'Debit Card',
      PaymentMethod.bankTransfer => 'Bank Transfer',
      PaymentMethod.paypal => 'PayPal',
      PaymentMethod.googlePay => 'Google Pay',
      PaymentMethod.applePay => 'Apple Pay',
      PaymentMethod.crypto => 'Cryptocurrency',
      PaymentMethod.other => 'Other',
    };
  }

  String get iconName {
    return switch (this) {
      PaymentMethod.creditCard => 'credit_card',
      PaymentMethod.debitCard => 'credit_card',
      PaymentMethod.bankTransfer => 'account_balance',
      PaymentMethod.paypal => 'payment',
      PaymentMethod.googlePay => 'payment',
      PaymentMethod.applePay => 'payment',
      PaymentMethod.crypto => 'currency_bitcoin',
      PaymentMethod.other => 'payment',
    };
  }
}
