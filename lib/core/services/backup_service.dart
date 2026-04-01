import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:subscription_tracker/data/datasources/local/database_helper.dart';
import 'package:subscription_tracker/core/utils/logger.dart';

/// Service for exporting and importing app data
class BackupService {
  final DatabaseHelper _databaseHelper;

  BackupService(this._databaseHelper);

  /// Export all data to JSON
  Future<String> exportToJson() async {
    try {
      final db = await _databaseHelper.database;

      // Get all subscriptions
      final subscriptions = await db.query('subscriptions');
      // Get all categories
      final categories = await db.query('categories');
      // Get all payment history
      final paymentHistory = await db.query('payment_history');

      final exportData = {
        'version': 1,
        'exportDate': DateTime.now().toIso8601String(),
        'subscriptions': subscriptions,
        'categories': categories,
        'payment_history': paymentHistory,
      };

      return jsonEncode(exportData);
    } catch (e) {
      AppLogger.e('Export failed: $e');
      throw Exception('Failed to export data: $e');
    }
  }

  /// Export and share file
  Future<void> exportAndShare() async {
    try {
      final jsonData = await exportToJson();
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/subscription_backup.json');
      await file.writeAsString(jsonData);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Subscription Tracker Backup',
        text: 'My subscription data backup',
      );
    } catch (e) {
      AppLogger.e('Share export failed: $e');
      throw Exception('Failed to share export: $e');
    }
  }

  /// Import data from JSON string
  Future<bool> importFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate version
      final version = data['version'] as int?;
      if (version == null || version > 1) {
        throw Exception('Unsupported backup version');
      }

      final db = await _databaseHelper.database;

      await db.transaction((txn) async {
        // Clear existing data
        await txn.delete('payment_history');
        await txn.delete('reminders');
        await txn.delete('subscriptions');

        // Import categories (keep defaults)
        final categories = data['categories'] as List<dynamic>?;
        if (categories != null) {
          for (final category in categories) {
            await txn.insert(
              'categories',
              category as Map<String, dynamic>,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        // Import subscriptions
        final subscriptions = data['subscriptions'] as List<dynamic>?;
        if (subscriptions != null) {
          for (final sub in subscriptions) {
            await txn.insert(
              'subscriptions',
              sub as Map<String, dynamic>,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        // Import payment history
        final history = data['payment_history'] as List<dynamic>?;
        if (history != null) {
          for (final payment in history) {
            await txn.insert(
              'payment_history',
              payment as Map<String, dynamic>,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      });

      AppLogger.i('Import completed successfully');
      return true;
    } catch (e) {
      AppLogger.e('Import failed: $e');
      throw Exception('Failed to import data: $e');
    }
  }

  /// Get backup file from picker (returns JSON string)
  Future<String?> pickBackupFile() async {
    // Note: File picker requires file_picker package
    // For now, this is a placeholder that returns null
    // In production, implement with file_picker
    return null;
  }
}
