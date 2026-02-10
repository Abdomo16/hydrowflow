import 'package:hydrowflow/database/app_database.dart';

class StatisticsRepository {
  Future<List<Map<String, dynamic>>> _allDays() async {
    try {
      final db = await AppDatabase.database;
      return db.query('daily_hydration', orderBy: 'date DESC');
    } catch (e) {
      return [];
    }
  }

  /// STREAK
  Future<int> getStreak(int targetCups) async {
    try {
      final rows = await _allDays();
      if (rows.isEmpty) return 0;

      int streak = 0;
      DateTime expectedDate = DateTime.now();
      final firstDate = DateTime.parse(rows.first['date'] as String);

      if (!_isSameDay(firstDate, expectedDate)) {
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      }

      for (final row in rows) {
        final rowDate = DateTime.parse(row['date'] as String);
        final cups = row['consumed_cups'] as int;

        if (!_isSameDay(rowDate, expectedDate)) break;

        if (cups >= targetCups) {
          streak++;
          expectedDate = expectedDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }

      return streak;
    } catch (e) {
      return 0;
    }
  }

  /// Returns cups for last recorded 7 days (including today if exists)
  Future<List<int>> getWeeklyCups() async {
    try {
      final db = await AppDatabase.database;

      final rows = await db.rawQuery('''
        SELECT date, consumed_cups
        FROM daily_hydration
        WHERE date >= date('now', '-6 days')
        ORDER BY date ASC
      ''');

      if (rows.isEmpty) return [];

      if (rows.length == 1) {
        return [(rows.first['consumed_cups'] as int)];
      }

      final cups = List<int>.filled(7, 0);
      for (int i = 0; i < rows.length && i < 7; i++) {
        cups[i] = rows[i]['consumed_cups'] as int;
      }

      return cups;
    } catch (e) {
      return [];
    }
  }

  /// MONTHLY STATS
  Future<Map<String, dynamic>> getMonthlyStats(int targetCups) async {
    try {
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
      String bestDay = '-';

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
    } catch (e) {
      return {'avg': 0.0, 'completion': 0.0, 'bestDay': '-'};
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
