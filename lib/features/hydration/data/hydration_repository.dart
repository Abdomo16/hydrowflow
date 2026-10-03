import 'package:intl/intl.dart';
import 'package:hydrowflow/database/app_database.dart';
import 'models/hydration_log.dart';

class HydrationRepository {
  static const int _mlPerCup = 250;

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _today() => _formatDate(DateTime.now());

  Future<void> _ensureDayRow(String date) async {
    final db = await AppDatabase.database;
    await db.rawInsert(
      '''
      INSERT OR IGNORE INTO daily_hydration (date, consumed_cups, total_ml)
      VALUES (?, 0, 0)
      ''',
      [date],
    );
  }

  Future<void> _recalculateDay(String date) async {
    final db = await AppDatabase.database;
    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount_ml), 0) as total_ml
      FROM hydration_logs
      WHERE date = ?
      ''',
      [date],
    );

    final totalMl = (result.first['total_ml'] as num).toInt();
    final cups = (totalMl / _mlPerCup).round();

    await db.update(
      'daily_hydration',
      {'consumed_cups': cups, 'total_ml': totalMl},
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<int> getTodayCups() async {
    final db = await AppDatabase.database;
    final today = _today();

    final result = await db.query(
      'daily_hydration',
      where: 'date = ?',
      whereArgs: [today],
    );

    if (result.isEmpty) {
      await db.insert('daily_hydration', {
        'date': today,
        'consumed_cups': 0,
        'total_ml': 0,
      });
      return 0;
    }

    return result.first['consumed_cups'] as int;
  }

  Future<int> getTodayMl() async {
    final db = await AppDatabase.database;
    final today = _today();

    final result = await db.query(
      'daily_hydration',
      where: 'date = ?',
      whereArgs: [today],
    );

    if (result.isEmpty) return 0;
    return result.first['total_ml'] as int? ?? 0;
  }

  Future<List<HydrationLog>> getTodayLogs() async {
    final db = await AppDatabase.database;
    final today = _today();

    final rows = await db.query(
      'hydration_logs',
      where: 'date = ?',
      whereArgs: [today],
      orderBy: 'created_at DESC',
    );

    return rows.map(HydrationLog.fromMap).toList();
  }

  Future<HydrationLog> addDrink(int amountMl) async {
    final db = await AppDatabase.database;
    final today = _today();
    final now = DateTime.now();

    await _ensureDayRow(today);

    final log = HydrationLog(
      date: today,
      amountMl: amountMl,
      createdAt: now,
    );

    final id = await db.insert('hydration_logs', log.toMap());
    await _recalculateDay(today);

    return log.copyWith(id: id);
  }

  /// Adds the standard cup size (250 ml).
  Future<HydrationLog> addCup() => addDrink(_mlPerCup);

  Future<void> deleteLog(int id) async {
    final db = await AppDatabase.database;

    final rows = await db.query(
      'hydration_logs',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (rows.isEmpty) return;

    final date = rows.first['date'] as String;

    await db.delete(
      'hydration_logs',
      where: 'id = ?',
      whereArgs: [id],
    );

    await _recalculateDay(date);
  }

  Future<HydrationLog?> undoLast() async {
    final db = await AppDatabase.database;
    final today = _today();

    final rows = await db.query(
      'hydration_logs',
      where: 'date = ?',
      whereArgs: [today],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final log = HydrationLog.fromMap(rows.first);
    await deleteLog(log.id!);

    return log;
  }
}
