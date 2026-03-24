import 'dart:convert';

import 'package:subscription_tracker/domain/entities/subscription.dart';

/// UserPreferences model for data layer
class UserPreferencesModel {
  final String? currencyCode;
  final String? languageCode;
  final int isDarkMode;
  final int notificationsEnabled;
  final String defaultReminderDays;
  final int biometricEnabled;
  final String? lastBackupDate;
  final String updatedAt;

  const UserPreferencesModel({
    this.currencyCode,
    this.languageCode,
    this.isDarkMode = 0,
    this.notificationsEnabled = 1,
    this.defaultReminderDays = '1,3,7',
    this.biometricEnabled = 0,
    this.lastBackupDate,
    required this.updatedAt,
  });

  factory UserPreferencesModel.fromEntity(UserPreferences entity) {
    return UserPreferencesModel(
      currencyCode: entity.currencyCode,
      languageCode: entity.languageCode,
      isDarkMode: entity.isDarkMode ? 1 : 0,
      notificationsEnabled: entity.notificationsEnabled ? 1 : 0,
      defaultReminderDays: entity.defaultReminderDays.join(','),
      biometricEnabled: entity.biometricEnabled ? 1 : 0,
      lastBackupDate: entity.lastBackupDate,
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  UserPreferences toEntity() {
    return UserPreferences(
      currencyCode: currencyCode,
      languageCode: languageCode,
      isDarkMode: isDarkMode == 1,
      notificationsEnabled: notificationsEnabled == 1,
      defaultReminderDays: defaultReminderDays.split(',').map((e) => int.tryParse(e) ?? 1).toList(),
      biometricEnabled: biometricEnabled == 1,
      lastBackupDate: lastBackupDate,
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  factory UserPreferencesModel.fromMap(Map<String, dynamic> map) {
    return UserPreferencesModel(
      currencyCode: map['currency_code'] as String?,
      languageCode: map['language_code'] as String?,
      isDarkMode: map['is_dark_mode'] as int? ?? 0,
      notificationsEnabled: map['notifications_enabled'] as int? ?? 1,
      defaultReminderDays: map['default_reminder_days'] as String? ?? '1,3,7',
      biometricEnabled: map['biometric_enabled'] as int? ?? 0,
      lastBackupDate: map['last_backup_date'] as String?,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currency_code': currencyCode,
      'language_code': languageCode,
      'is_dark_mode': isDarkMode,
      'notifications_enabled': notificationsEnabled,
      'default_reminder_days': defaultReminderDays,
      'biometric_enabled': biometricEnabled,
      'last_backup_date': lastBackupDate,
      'updated_at': updatedAt,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory UserPreferencesModel.fromJson(String source) =>
      UserPreferencesModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
