import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'hydration.db');

    return openDatabase(
      path,
      version: 4, // ⬅️ زودنا الفيرجن
      onCreate: (db, _) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // v2 migration
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS daily_hydration (
              date TEXT PRIMARY KEY,
              consumed_cups INTEGER
            )
          ''');
        }

        // v3 migration (Reminders)
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS reminder_settings (
              id INTEGER PRIMARY KEY,
              enabled INTEGER,
              frequency_minutes INTEGER,
              wake_time TEXT,
              sleep_time TEXT
            )
          ''');
        }

        // v4 migration (Sound)
        if (oldVersion < 4) {
          await db.execute(
            "ALTER TABLE reminder_settings ADD COLUMN sound TEXT",
          );
        }
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY,
        height REAL,
        weight REAL,
        activity_level TEXT,
        daily_goal REAL,
        onboarding_done INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_hydration (
        date TEXT PRIMARY KEY,
        consumed_cups INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE reminder_settings (
        id INTEGER PRIMARY KEY,
        enabled INTEGER,
        frequency_minutes INTEGER,
        wake_time TEXT,
        sleep_time TEXT,
        sound TEXT
      )
    ''');
  }
}
