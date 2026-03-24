import 'dart:convert';

import 'package:subscription_tracker/domain/entities/subscription.dart';

/// PaymentHistory model for data layer
class PaymentHistoryModel {
  final String id;
  final String subscriptionId;
  final String paymentDate;
  final double amount;
  final String currency;
  final String? notes;
  final String createdAt;

  const PaymentHistoryModel({
    required this.id,
    required this.subscriptionId,
    required this.paymentDate,
    required this.amount,
    required this.currency,
    this.notes,
    required this.createdAt,
  });

  factory PaymentHistoryModel.fromEntity(PaymentHistory entity) {
    return PaymentHistoryModel(
      id: entity.id,
      subscriptionId: entity.subscriptionId,
      paymentDate: entity.paymentDate.toIso8601String(),
      amount: entity.amount,
      currency: entity.currency,
      notes: entity.notes,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }

  PaymentHistory toEntity() {
    return PaymentHistory(
      id: id,
      subscriptionId: subscriptionId,
      paymentDate: DateTime.parse(paymentDate),
      amount: amount,
      currency: currency,
      notes: notes,
      createdAt: DateTime.parse(createdAt),
    );
  }

  factory PaymentHistoryModel.fromMap(Map<String, dynamic> map) {
    return PaymentHistoryModel(
      id: map['id'] as String,
      subscriptionId: map['subscription_id'] as String,
      paymentDate: map['payment_date'] as String,
      amount: map['amount'] as double,
      currency: map['currency'] as String,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subscription_id': subscriptionId,
      'payment_date': paymentDate,
      'amount': amount,
      'currency': currency,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory PaymentHistoryModel.fromJson(String source) =>
      PaymentHistoryModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
