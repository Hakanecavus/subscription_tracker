import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:subscription_tracker/core/constants/app_constants.dart';
import 'package:subscription_tracker/core/constants/routes.dart';
import 'package:subscription_tracker/core/utils/logger.dart';

/// Database helper for SQLite operations
class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  /// Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    AppLogger.i('Initializing database at: $path');

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create tables
  Future<void> _onCreate(Database db, int version) async {
    AppLogger.i('Creating database tables...');

    // Categories table
    await db.execute('''
      CREATE TABLE ${DatabaseTables.categories} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        color_value INTEGER NOT NULL,
        icon_name TEXT,
        is_default INTEGER DEFAULT 0,
        sort_order INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Subscriptions table
    await db.execute('''
      CREATE TABLE ${DatabaseTables.subscriptions} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        billing_cycle TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        next_billing_date TEXT NOT NULL,
        category_id TEXT,
        icon_url TEXT,
        website_url TEXT,
        payment_method TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        has_reminder INTEGER DEFAULT 0,
        reminder_days TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES ${DatabaseTables.categories}(id)
      )
    ''');

    // Payment history table
    await db.execute('''
      CREATE TABLE ${DatabaseTables.paymentHistory} (
        id TEXT PRIMARY KEY,
        subscription_id TEXT NOT NULL,
        payment_date TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (subscription_id) REFERENCES ${DatabaseTables.subscriptions}(id)
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE ${DatabaseTables.settings} (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Reminders table
    await db.execute('''
      CREATE TABLE ${DatabaseTables.reminders} (
        id TEXT PRIMARY KEY,
        subscription_id TEXT NOT NULL,
        reminder_date TEXT NOT NULL,
        is_triggered INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (subscription_id) REFERENCES ${DatabaseTables.subscriptions}(id)
      )
    ''');

    // Create indexes
    await db.execute('''
      CREATE INDEX idx_subscriptions_category
      ON ${DatabaseTables.subscriptions}(category_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_subscriptions_billing_date
      ON ${DatabaseTables.subscriptions}(next_billing_date)
    ''');

    await db.execute('''
      CREATE INDEX idx_payment_history_subscription
      ON ${DatabaseTables.paymentHistory}(subscription_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_reminders_subscription
      ON ${DatabaseTables.reminders}(subscription_id)
    ''');
  }

  /// Upgrade database
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.i('Upgrading database from $oldVersion to $newVersion');
    // Migration logic here
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    AppLogger.i('Database closed');
  }

  /// Delete database
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
    AppLogger.i('Database deleted');
  }

  /// Execute raw query
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  /// Execute raw insert
  Future<int> rawInsert(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawInsert(sql, arguments);
  }

  /// Execute raw update
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawUpdate(sql, arguments);
  }

  /// Execute raw delete
  Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawDelete(sql, arguments);
  }
}
