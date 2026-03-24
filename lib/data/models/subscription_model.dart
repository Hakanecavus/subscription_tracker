import 'dart:convert';

import 'package:subscription_tracker/domain/entities/subscription.dart';

/// Subscription model for data layer
class SubscriptionModel {
  final String id;
  final String name;
  final String? description;
  final double amount;
  final String currency;
  final String billingCycle;
  final String startDate;
  final String? endDate;
  final String nextBillingDate;
  final String? categoryId;
  final String? iconUrl;
  final String? websiteUrl;
  final String paymentMethod;
  final int isActive;
  final int hasReminder;
  final String? reminderDays;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  const SubscriptionModel({
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
    this.isActive = 1,
    this.hasReminder = 0,
    this.reminderDays,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert from entity
  factory SubscriptionModel.fromEntity(Subscription entity) {
    return SubscriptionModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      amount: entity.amount,
      currency: entity.currency,
      billingCycle: entity.billingCycle.name,
      startDate: entity.startDate.toIso8601String(),
      endDate: entity.endDate?.toIso8601String(),
      nextBillingDate: entity.nextBillingDate.toIso8601String(),
      categoryId: entity.categoryId,
      iconUrl: entity.iconUrl,
      websiteUrl: entity.websiteUrl,
      paymentMethod: entity.paymentMethod.name,
      isActive: entity.isActive ? 1 : 0,
      hasReminder: entity.hasReminder ? 1 : 0,
      reminderDays: entity.reminderDays?.join(','),
      notes: entity.notes,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  /// Convert to entity
  Subscription toEntity() {
    return Subscription(
      id: id,
      name: name,
      description: description,
      amount: amount,
      currency: currency,
      billingCycle: BillingCycle.values.firstWhere(
        (e) => e.name == billingCycle,
        orElse: () => BillingCycle.monthly,
      ),
      startDate: DateTime.parse(startDate),
      endDate: endDate != null ? DateTime.parse(endDate!) : null,
      nextBillingDate: DateTime.parse(nextBillingDate),
      categoryId: categoryId,
      iconUrl: iconUrl,
      websiteUrl: websiteUrl,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == paymentMethod,
        orElse: () => PaymentMethod.other,
      ),
      isActive: isActive == 1,
      hasReminder: hasReminder == 1,
      reminderDays: reminderDays?.split(',').map(int.parse).toList(),
      notes: notes,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// Convert from database map
  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      amount: map['amount'] as double,
      currency: map['currency'] as String,
      billingCycle: map['billing_cycle'] as String,
      startDate: map['start_date'] as String,
      endDate: map['end_date'] as String?,
      nextBillingDate: map['next_billing_date'] as String,
      categoryId: map['category_id'] as String?,
      iconUrl: map['icon_url'] as String?,
      websiteUrl: map['website_url'] as String?,
      paymentMethod: map['payment_method'] as String,
      isActive: map['is_active'] as int? ?? 1,
      hasReminder: map['has_reminder'] as int? ?? 0,
      reminderDays: map['reminder_days'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'amount': amount,
      'currency': currency,
      'billing_cycle': billingCycle,
      'start_date': startDate,
      'end_date': endDate,
      'next_billing_date': nextBillingDate,
      'category_id': categoryId,
      'icon_url': iconUrl,
      'website_url': websiteUrl,
      'payment_method': paymentMethod,
      'is_active': isActive,
      'has_reminder': hasReminder,
      'reminder_days': reminderDays,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Copy with method
  SubscriptionModel copyWith({
    String? id,
    String? name,
    String? description,
    double? amount,
    String? currency,
    String? billingCycle,
    String? startDate,
    String? endDate,
    String? nextBillingDate,
    String? categoryId,
    String? iconUrl,
    String? websiteUrl,
    String? paymentMethod,
    int? isActive,
    int? hasReminder,
    String? reminderDays,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) {
    return SubscriptionModel(
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

  /// Convert to JSON
  String toJson() => jsonEncode(toMap());

  /// Convert from JSON
  factory SubscriptionModel.fromJson(String source) =>
      SubscriptionModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
