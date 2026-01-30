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
      version: 2,
      onCreate: (db, _) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS daily_hydration (
              date TEXT PRIMARY KEY,
              consumed_cups INTEGER
            )
          ''');
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
  }
}
