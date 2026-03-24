import 'package:sqflite/sqflite.dart';
import 'package:subscription_tracker/core/constants/routes.dart';
import 'package:subscription_tracker/core/utils/logger.dart';
import 'package:subscription_tracker/data/datasources/local/database_helper.dart';
import 'package:subscription_tracker/data/models/subscription_model.dart';

/// Local data source for subscription operations
abstract class SubscriptionLocalDataSource {
  /// Get all subscriptions
  Future<List<SubscriptionModel>> getAll();

  /// Get active subscriptions
  Future<List<SubscriptionModel>> getActive();

  /// Get subscription by ID
  Future<SubscriptionModel?> getById(String id);

  /// Get subscriptions by category
  Future<List<SubscriptionModel>> getByCategory(String categoryId);

  /// Get subscriptions due within days
  Future<List<SubscriptionModel>> getDueWithinDays(int days);

  /// Get total monthly cost
  Future<double> getTotalMonthlyCost();

  /// Get total yearly cost
  Future<double> getTotalYearlyCost();

  /// Insert subscription
  Future<SubscriptionModel> insert(SubscriptionModel subscription);

  /// Update subscription
  Future<SubscriptionModel> update(SubscriptionModel subscription);

  /// Delete subscription
  Future<void> delete(String id);

  /// Search subscriptions
  Future<List<SubscriptionModel>> search(String query);

  /// Get subscription count
  Future<int> getCount();

  /// Update next billing date
  Future<SubscriptionModel?> updateBillingDate(String id, DateTime nextBillingDate);
}

/// Implementation of SubscriptionLocalDataSource
class SubscriptionLocalDataSourceImpl implements SubscriptionLocalDataSource {
  final DatabaseHelper _dbHelper;

  SubscriptionLocalDataSourceImpl({required DatabaseHelper dbHelper}) : _dbHelper = dbHelper;

  @override
  Future<List<SubscriptionModel>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseTables.subscriptions,
      orderBy: 'next_billing_date ASC',
    );
    return maps.map((map) => SubscriptionModel.fromMap(map)).toList();
  }

  @override
  Future<List<SubscriptionModel>> getActive() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseTables.subscriptions,
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'next_billing_date ASC',
    );
    return maps.map((map) => SubscriptionModel.fromMap(map)).toList();
  }

  @override
  Future<SubscriptionModel?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseTables.subscriptions,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return SubscriptionModel.fromMap(maps.first);
  }

  @override
  Future<List<SubscriptionModel>> getByCategory(String categoryId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseTables.subscriptions,
      where: 'category_id = ? AND is_active = ?',
      whereArgs: [categoryId, 1],
      orderBy: 'name ASC',
    );
    return maps.map((map) => SubscriptionModel.fromMap(map)).toList();
  }

  @override
  Future<List<SubscriptionModel>> getDueWithinDays(int days) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    final future = DateTime.now().add(Duration(days: days)).toIso8601String();

    final maps = await db.query(
      DatabaseTables.subscriptions,
      where: 'next_billing_date BETWEEN ? AND ? AND is_active = ?',
      whereArgs: [now, future, 1],
      orderBy: 'next_billing_date ASC',
    );
    return maps.map((map) => SubscriptionModel.fromMap(map)).toList();
  }

  @override
  Future<double> getTotalMonthlyCost() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(
        CASE billing_cycle
          WHEN 'weekly' THEN amount * 4.33
          WHEN 'biWeekly' THEN amount * 2.17
          WHEN 'monthly' THEN amount
          WHEN 'quarterly' THEN amount / 3
          WHEN 'halfYearly' THEN amount / 6
          WHEN 'yearly' THEN amount / 12
          ELSE amount
        END
      ) as total
      FROM ${DatabaseTables.subscriptions}
      WHERE is_active = 1
    ''');

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  @override
  Future<double> getTotalYearlyCost() async {
    final monthlyCost = await getTotalMonthlyCost();
    return monthlyCost * 12;
  }

  @override
  Future<SubscriptionModel> insert(SubscriptionModel subscription) async {
    final db = await _dbHelper.database;
    await db.insert(
      DatabaseTables.subscriptions,
      subscription.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    AppLogger.logDb('INSERT', table: DatabaseTables.subscriptions, data: subscription.id);
    return subscription;
  }

  @override
  Future<SubscriptionModel> update(SubscriptionModel subscription) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseTables.subscriptions,
      subscription.toMap(),
      where: 'id = ?',
      whereArgs: [subscription.id],
    );
    AppLogger.logDb('UPDATE', table: DatabaseTables.subscriptions, data: subscription.id);
    return subscription;
  }

  @override
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseTables.subscriptions,
      where: 'id = ?',
      whereArgs: [id],
    );
    AppLogger.logDb('DELETE', table: DatabaseTables.subscriptions, data: id);
  }

  @override
  Future<List<SubscriptionModel>> search(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseTables.subscriptions,
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => SubscriptionModel.fromMap(map)).toList();
  }

  @override
  Future<int> getCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseTables.subscriptions} WHERE is_active = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<SubscriptionModel?> updateBillingDate(String id, DateTime nextBillingDate) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseTables.subscriptions,
      {'next_billing_date': nextBillingDate.toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
    return await getById(id);
  }
}
