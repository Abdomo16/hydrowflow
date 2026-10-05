import 'package:hydrowflow/database/app_database.dart';

class StatisticsRepository {
  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);

  /// STREAK
  /// Today only counts once its goal is reached, so an unfinished today
  /// doesn't break a streak built on previous days.
  Future<int> getStreak(int targetCups) async {
    try {
      final db = await AppDatabase.database;
      final rows = await db.query('daily_hydration', orderBy: 'date DESC');
      if (rows.isEmpty) return 0;

      final today = _today();
      var expectedDate = today;
      var streak = 0;

      for (final row in rows) {
        final rowDate = DateTime.parse(row['date'] as String);
        final cups = row['consumed_cups'] as int;

        if (_isSameDay(rowDate, today) && cups < targetCups) continue;
        if (_isSameDay(expectedDate, today) && !_isSameDay(rowDate, today)) {
          expectedDate = _addDays(today, -1);
        }

        if (!_isSameDay(rowDate, expectedDate) || cups < targetCups) break;

        streak++;
        expectedDate = _addDays(expectedDate, -1);
      }

      return streak;
    } catch (e) {
      return 0;
    }
  }

  /// Returns cups for the current calendar week (Mon-Sun), aligned to weekday labels.
  Future<List<int>> getWeeklyCups() async {
    try {
      final db = await AppDatabase.database;
      final today = _today();
      final weekStart = _addDays(today, -(today.weekday - 1));

      final rows = await db.query(
        'daily_hydration',
        columns: ['date', 'consumed_cups'],
        where: 'date >= ? AND date <= ?',
        whereArgs: [_formatDate(weekStart), _formatDate(_addDays(weekStart, 6))],
      );

      final cups = List<int>.filled(7, 0);
      for (final row in rows) {
        final rowDate = DateTime.parse(row['date'] as String);
        cups[rowDate.weekday - 1] = row['consumed_cups'] as int;
      }

      return cups;
    } catch (e) {
      return List<int>.filled(7, 0);
    }
  }

  /// Returns cups for the current calendar month, grouped by week of month:
  /// W1 = days 1-7, W2 = 8-14, W3 = 15-21, W4 = 22-28, W5 = 29-31.
  Future<List<int>> getMonthlyCups() async {
    final today = _today();
    final cups = List<int>.filled(weeksInMonth(today), 0);

    try {
      final db = await AppDatabase.database;
      final monthStart = DateTime(today.year, today.month, 1);
      final monthEnd = DateTime(today.year, today.month + 1, 0);

      final rows = await db.query(
        'daily_hydration',
        columns: ['date', 'consumed_cups'],
        where: 'date >= ? AND date <= ?',
        whereArgs: [_formatDate(monthStart), _formatDate(monthEnd)],
      );

      for (final row in rows) {
        final rowDate = DateTime.parse(row['date'] as String);
        cups[weekOfMonth(rowDate)] += row['consumed_cups'] as int;
      }

      return cups;
    } catch (e) {
      return cups;
    }
  }

  static int weekOfMonth(DateTime date) => (date.day - 1) ~/ 7;

  static int weeksInMonth(DateTime date) {
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    return (daysInMonth / 7).ceil();
  }

  /// MONTHLY STATS for the current calendar month.
  /// Counted days run from the 1st (or the first day the app was used, if
  /// later) up to yesterday, plus today once its goal is reached.
  Future<Map<String, dynamic>> getMonthlyStats(int targetCups) async {
    const empty = {'avg': 0.0, 'completion': 0.0, 'bestDay': '-'};

    try {
      final db = await AppDatabase.database;
      final today = _today();
      final monthStart = DateTime(today.year, today.month, 1);

      final firstRow = await db.rawQuery(
        'SELECT MIN(date) AS first_date FROM daily_hydration',
      );
      final firstDateStr = firstRow.first['first_date'] as String?;
      if (firstDateStr == null) return empty;

      final firstUsed = DateTime.parse(firstDateStr);
      final rangeStart = firstUsed.isAfter(monthStart) ? firstUsed : monthStart;

      final rows = await db.query(
        'daily_hydration',
        columns: ['date', 'consumed_cups'],
        where: 'date >= ? AND date <= ?',
        whereArgs: [_formatDate(rangeStart), _formatDate(today)],
      );

      var todayCups = 0;
      var total = 0;
      var completedDays = 0;
      var best = 0;
      var bestDay = '-';

      for (final r in rows) {
        final date = r['date'] as String;
        final cups = r['consumed_cups'] as int;

        if (cups > best) {
          best = cups;
          bestDay = date;
        }

        if (date == _formatDate(today)) {
          todayCups = cups;
          continue;
        }

        total += cups;
        if (cups >= targetCups) completedDays++;
      }

      var countedDays = DateTime.utc(today.year, today.month, today.day)
          .difference(
            DateTime.utc(rangeStart.year, rangeStart.month, rangeStart.day),
          )
          .inDays;
      if (todayCups >= targetCups && targetCups > 0) {
        countedDays++;
        total += todayCups;
        completedDays++;
      }

      if (countedDays <= 0) {
        return {'avg': 0.0, 'completion': 0.0, 'bestDay': bestDay};
      }

      return {
        'avg': total / countedDays,
        'completion': (completedDays / countedDays) * 100,
        'bestDay': bestDay,
      };
    } catch (e) {
      return empty;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
