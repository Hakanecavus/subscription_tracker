import 'package:sqflite/sqflite.dart';
import 'package:subscription_tracker/core/constants/routes.dart';
import 'package:subscription_tracker/core/utils/logger.dart';
import 'package:subscription_tracker/data/datasources/local/database_helper.dart';
import 'package:subscription_tracker/data/models/category_model.dart';

/// Local data source for category operations
abstract class CategoryLocalDataSource {
  /// Get all categories
  Future<List<CategoryModel>> getAll();

  /// Get category by ID
  Future<CategoryModel?> getById(String id);

  /// Insert category
  Future<CategoryModel> insert(CategoryModel category);

  /// Update category
  Future<CategoryModel> update(CategoryModel category);

  /// Delete category
  Future<void> delete(String id);

  /// Get default categories
  Future<List<CategoryModel>> getDefaults();

  /// Get custom categories
  Future<List<CategoryModel>> getCustom();

  /// Initialize default categories
  Future<void> initializeDefaults();

  /// Get subscription counts by category
  Future<Map<String, int>> getSubscriptionCounts();

  /// Check if categories exist
  Future<bool> hasCategories();
}

/// Implementation of CategoryLocalDataSource
class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final DatabaseHelper _dbHelper;

  CategoryLocalDataSourceImpl({required DatabaseHelper dbHelper}) : _dbHelper = dbHelper;

  @override
  Future<List<CategoryModel>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseTables.categories,
      orderBy: 'sort_order ASC, name ASC',
    );
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  @override
  Future<CategoryModel?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseTables.categories,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return CategoryModel.fromMap(maps.first);
  }

  @override
  Future<CategoryModel> insert(CategoryModel category) async {
    final db = await _dbHelper.database;
    await db.insert(
      DatabaseTables.categories,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    AppLogger.logDb('INSERT', table: DatabaseTables.categories, data: category.id);
    return category;
  }

  @override
  Future<CategoryModel> update(CategoryModel category) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseTables.categories,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
    AppLogger.logDb('UPDATE', table: DatabaseTables.categories, data: category.id);
    return category;
  }

  @override
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseTables.categories,
      where: 'id = ?',
      whereArgs: [id],
    );
    AppLogger.logDb('DELETE', table: DatabaseTables.categories, data: id);
  }

  @override
  Future<List<CategoryModel>> getDefaults() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseTables.categories,
      where: 'is_default = ?',
      whereArgs: [1],
      orderBy: 'sort_order ASC',
    );
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  @override
  Future<List<CategoryModel>> getCustom() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseTables.categories,
      where: 'is_default = ?',
      whereArgs: [0],
      orderBy: 'name ASC',
    );
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  @override
  Future<void> initializeDefaults() async {
    final existing = await getDefaults();
    if (existing.isNotEmpty) return;

    final db = await _dbHelper.database;
    final batch = db.batch();

    final now = DateTime.now().toIso8601String();
    final defaults = DefaultCategories.all.map((cat) {
      return cat.copyWith(createdAt: now).toMap();
    });

    for (final category in defaults) {
      batch.insert(DatabaseTables.categories, category);
    }

    await batch.commit(noResult: true);
    AppLogger.logDb('INSERT DEFAULTS', table: DatabaseTables.categories, result: defaults.length);
  }

  @override
  Future<Map<String, int>> getSubscriptionCounts() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT c.id, COUNT(s.id) as count
      FROM ${DatabaseTables.categories} c
      LEFT JOIN ${DatabaseTables.subscriptions} s ON c.id = s.category_id AND s.is_active = 1
      GROUP BY c.id
    ''');

    return {
      for (var row in result) row['id'] as String: (row['count'] as int?) ?? 0
    };
  }

  @override
  Future<bool> hasCategories() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseTables.categories}',
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }
}
