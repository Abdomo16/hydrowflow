import 'package:intl/intl.dart';
import 'package:hydrowflow/database/app_database.dart';

class HydrationRepository {
  String _today() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
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
      await db.insert('daily_hydration', {'date': today, 'consumed_cups': 0});
      return 0;
    }

    return result.first['consumed_cups'] as int;
  }

  Future<void> addCup() async {
    final db = await AppDatabase.database;
    final today = _today();

    await getTodayCups();

    await db.rawUpdate(
      '''
      UPDATE daily_hydration
      SET consumed_cups = consumed_cups + 1
      WHERE date = ?
      ''',
      [today],
    );
  }
}
