import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/lenten_day.dart';
import '../models/guarded_app.dart';
import '../models/intervention.dart';
import '../models/user_settings.dart';
import 'seed_data.dart';

/// Singleton database helper for Selah.
/// All data is stored locally — no network calls, no cloud, no analytics.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'selah.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create lenten_days table
    await db.execute('''
      CREATE TABLE lenten_days (
        id INTEGER PRIMARY KEY,
        season TEXT NOT NULL,
        liturgical_label TEXT NOT NULL,
        scripture_ref TEXT NOT NULL,
        scripture_text TEXT NOT NULL,
        breath_prayer TEXT NOT NULL,
        reflection TEXT NOT NULL,
        companion_name TEXT,
        companion_quote TEXT
      )
    ''');

    // Create guarded_apps table
    await db.execute('''
      CREATE TABLE guarded_apps (
        package_name TEXT PRIMARY KEY,
        app_name TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        added_at TEXT NOT NULL
      )
    ''');

    // Create interventions table
    await db.execute('''
      CREATE TABLE interventions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        app_package TEXT NOT NULL,
        outcome TEXT NOT NULL,
        reason TEXT,
        offering_text TEXT,
        scripture_shown TEXT NOT NULL,
        pause_duration INTEGER NOT NULL,
        attempt_number INTEGER NOT NULL,
        time_saved_est INTEGER NOT NULL DEFAULT 300
      )
    ''');

    // Create user_settings table (single row)
    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY DEFAULT 1,
        tradition TEXT NOT NULL DEFAULT 'exploring',
        language TEXT NOT NULL DEFAULT 'en',
        schedule_mode TEXT NOT NULL DEFAULT 'always',
        custom_start TEXT,
        custom_end TEXT,
        custom_days TEXT,
        is_premium INTEGER NOT NULL DEFAULT 0,
        armor_locked INTEGER NOT NULL DEFAULT 0,
        armor_lock_until TEXT,
        friction_start_sec INTEGER NOT NULL DEFAULT 5,
        notifications_morning INTEGER NOT NULL DEFAULT 0,
        notifications_midday INTEGER NOT NULL DEFAULT 0,
        notifications_evening INTEGER NOT NULL DEFAULT 0,
        notifications_celebration INTEGER NOT NULL DEFAULT 0,
        notifications_weekly INTEGER NOT NULL DEFAULT 1,
        onboarding_complete INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Insert default user settings
    await db.insert('user_settings', {
      'id': 1,
      'tradition': 'exploring',
      'language': 'en',
      'schedule_mode': 'always',
      'is_premium': 0,
      'armor_locked': 0,
      'friction_start_sec': 5,
      'notifications_morning': 0,
      'notifications_midday': 0,
      'notifications_evening': 0,
      'notifications_celebration': 0,
      'notifications_weekly': 1,
      'onboarding_complete': 0,
    });

    // Create index for faster intervention queries
    await db.execute('''
      CREATE INDEX idx_interventions_date ON interventions(timestamp)
    ''');

    await db.execute('''
      CREATE INDEX idx_interventions_app ON interventions(app_package)
    ''');

    debugPrint('DatabaseHelper: Database created successfully');
  }

  // ============================================================
  // INTERVENTIONS
  // ============================================================

  /// Insert a new intervention record
  Future<int> insertIntervention(Intervention intervention) async {
    final db = await database;
    final map = intervention.toMap();
    map.remove('id'); // Let SQLite auto-generate the ID
    return await db.insert('interventions', map);
  }

  /// Get all interventions for a specific date
  Future<List<Intervention>> getInterventionsForDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final results = await db.query(
      'interventions',
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'timestamp DESC',
    );

    return results.map((map) => Intervention.fromMap(map)).toList();
  }

  /// Get today's attempt count for a specific app
  Future<int> getTodayAttemptsForApp(String packageName) async {
    final db = await database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM interventions WHERE app_package = ? AND timestamp >= ? AND timestamp < ?',
      [packageName, startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get total resistances for today
  Future<int> getTodayResistances() async {
    final db = await database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM interventions WHERE outcome = 'resisted' AND timestamp >= ? AND timestamp < ?",
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get time reclaimed today in seconds
  Future<int> getTodayTimeReclaimed() async {
    final db = await database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.rawQuery(
      "SELECT SUM(time_saved_est) as total FROM interventions WHERE outcome = 'resisted' AND timestamp >= ? AND timestamp < ?",
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ============================================================
  // GUARDED APPS
  // ============================================================

  /// Get all guarded apps
  Future<List<GuardedApp>> getGuardedApps({bool activeOnly = false}) async {
    final db = await database;

    List<Map<String, dynamic>> results;
    if (activeOnly) {
      results = await db.query(
        'guarded_apps',
        where: 'is_active = 1',
        orderBy: 'added_at DESC',
      );
    } else {
      results = await db.query('guarded_apps', orderBy: 'added_at DESC');
    }

    return results.map((map) => GuardedApp.fromMap(map)).toList();
  }

  /// Get count of active guarded apps
  Future<int> getActiveGuardedAppsCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM guarded_apps WHERE is_active = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Insert or update a guarded app
  Future<void> upsertGuardedApp(GuardedApp app) async {
    final db = await database;
    await db.insert(
      'guarded_apps',
      app.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update a guarded app's active status
  Future<void> updateGuardedApp(String packageName, {required bool isActive}) async {
    final db = await database;
    await db.update(
      'guarded_apps',
      {'is_active': isActive ? 1 : 0},
      where: 'package_name = ?',
      whereArgs: [packageName],
    );
  }

  /// Remove a guarded app
  Future<void> removeGuardedApp(String packageName) async {
    final db = await database;
    await db.delete(
      'guarded_apps',
      where: 'package_name = ?',
      whereArgs: [packageName],
    );
  }

  /// Check if an app is guarded
  Future<bool> isAppGuarded(String packageName) async {
    final db = await database;
    final result = await db.query(
      'guarded_apps',
      where: 'package_name = ? AND is_active = 1',
      whereArgs: [packageName],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // ============================================================
  // USER SETTINGS
  // ============================================================

  /// Get user settings
  Future<UserSettings> getUserSettings() async {
    final db = await database;
    final results = await db.query('user_settings', limit: 1);

    if (results.isEmpty) {
      // Insert default settings if none exist
      await db.insert('user_settings', UserSettings.defaults().toMap());
      return UserSettings.defaults();
    }

    return UserSettings.fromMap(results.first);
  }

  /// Update user settings
  Future<void> updateUserSettings(UserSettings settings) async {
    final db = await database;
    await db.update(
      'user_settings',
      settings.toMap(),
      where: 'id = 1',
    );
  }

  /// Update a single setting
  Future<void> updateSetting(String key, dynamic value) async {
    final db = await database;
    await db.update(
      'user_settings',
      {key: value},
      where: 'id = 1',
    );
  }

  // ============================================================
  // LENTEN DAYS / CONTENT
  // ============================================================

  /// Get a specific day's content
  Future<LentenDay?> getLentenDay(int dayNumber) async {
    final db = await database;
    final results = await db.query(
      'lenten_days',
      where: 'id = ?',
      whereArgs: [dayNumber],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return LentenDay.fromMap(results.first);
  }

  /// Get all days for a season
  Future<List<LentenDay>> getDaysForSeason(String season) async {
    final db = await database;
    final results = await db.query(
      'lenten_days',
      where: 'season = ?',
      whereArgs: [season],
      orderBy: 'id ASC',
    );

    return results.map((map) => LentenDay.fromMap(map)).toList();
  }

  /// Insert a Lenten day (used by seed_data)
  Future<void> insertLentenDay(LentenDay day) async {
    final db = await database;
    await db.insert(
      'lenten_days',
      day.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Check if content needs seeding
  Future<bool> needsSeeding() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM lenten_days',
    );
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count == 0;
  }

  /// Seed content from JSON files if needed
  Future<void> seedContentIfNeeded() async {
    if (await needsSeeding()) {
      debugPrint('DatabaseHelper: Seeding content...');
      await SeedData.seedAll(this);
      debugPrint('DatabaseHelper: Content seeded successfully');
    }
  }

  // ============================================================
  // UTILITIES
  // ============================================================

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Delete all data (for testing/reset)
  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('interventions');
    await db.delete('guarded_apps');
    await db.update('user_settings', UserSettings.defaults().toMap(), where: 'id = 1');
  }
}
