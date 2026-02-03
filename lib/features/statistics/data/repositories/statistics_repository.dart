import 'package:hydrowflow/database/app_database.dart';

class StatisticsRepository {
  Future<List<Map<String, dynamic>>> _allDays() async {
    final db = await AppDatabase.database;
    return db.query(
      'daily_hydration',
      orderBy: 'date DESC', // newest first
    );
  }

  ///  STREAK (FIXED – real consecutive days, D1 supported)
  Future<int> getStreak(int targetCups) async {
    final rows = await _allDays();

    if (rows.isEmpty) return 0;

    int streak = 0;

    DateTime expectedDate = DateTime.now();

    for (final row in rows) {
      final rowDate = DateTime.parse(row['date'] as String);
      final cups = row['consumed_cups'] as int;

      if (!_isSameDay(rowDate, expectedDate)) {
        break;
      }

      if (cups >= targetCups) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// WEEKLY (D1 supported)
  Future<List<int>> getWeeklyCups() async {
    final db = await AppDatabase.database;

    final rows = await db.rawQuery('''
      SELECT date, consumed_cups
      FROM daily_hydration
      WHERE date >= date('now', '-6 days')
      ORDER BY date ASC
    ''');

    // D1 → show one bar only
    if (rows.length == 1) {
      return [(rows.first['consumed_cups'] as int)];
    }

    final cups = List<int>.filled(7, 0);

    for (int i = 0; i < rows.length && i < 7; i++) {
      cups[i] = rows[i]['consumed_cups'] as int;
    }

    return cups;
  }

  ///  MONTHLY (D1 supported)
  Future<Map<String, dynamic>> getMonthlyStats(int targetCups) async {
    final db = await AppDatabase.database;

    final rows = await db.rawQuery('''
      SELECT date, consumed_cups
      FROM daily_hydration
      WHERE date >= date('now', '-30 days')
      ORDER BY date ASC
    ''');

    if (rows.isEmpty) {
      return {'avg': 0.0, 'completion': 0.0, 'bestDay': '-'};
    }

    // D1 logic
    if (rows.length == 1) {
      final cups = rows.first['consumed_cups'] as int;
      return {
        'avg': cups.toDouble(),
        'completion': cups >= targetCups ? 100.0 : 0.0,
        'bestDay': rows.first['date'] as String,
      };
    }

    int total = 0;
    int completedDays = 0;
    int best = 0;
    String bestDay = '';

    for (final r in rows) {
      final cups = r['consumed_cups'] as int;
      total += cups;

      if (cups >= targetCups) completedDays++;
      if (cups > best) {
        best = cups;
        bestDay = r['date'] as String;
      }
    }

    return {
      'avg': total / rows.length,
      'completion': (completedDays / rows.length) * 100,
      'bestDay': bestDay,
    };
  }

  ///  helper
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
