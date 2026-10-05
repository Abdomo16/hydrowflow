class ReminderSlot {
  final DateTime at;

  /// True for reminders in the active day's window, where live progress
  /// (e.g. "750 ml to go") is still accurate.
  final bool isCurrentDay;

  const ReminderSlot(this.at, {required this.isCurrentDay});
}

/// Plans reminder times inside each day's wake-sleep window.
///
/// Times are anchored to the last drink in the window (or the wake time if
/// none yet) and repeat every [intervalMinutes], so rescheduling at any moment
/// produces the same times until the user drinks again.
List<ReminderSlot> planReminders({
  required int intervalMinutes,
  required String wakeTime,
  required String sleepTime,
  required DateTime now,
  required bool goalReachedToday,
  DateTime? lastDrinkAt,
  int daysAhead = 3,
  int maxCount = 60,
}) {
  if (intervalMinutes <= 0 || maxCount <= 0) return const [];

  final interval = Duration(minutes: intervalMinutes);
  final earliest = now.add(const Duration(minutes: 1));
  final today = DateTime(now.year, now.month, now.day);
  final slots = <ReminderSlot>[];

  // Start from yesterday so a window that crosses midnight is still covered.
  for (var offset = -1; offset < daysAhead; offset++) {
    final day = DateTime(today.year, today.month, today.day + offset);
    final start = _at(day, wakeTime);
    var end = _at(day, sleepTime);
    if (!end.isAfter(start)) {
      end = DateTime(end.year, end.month, end.day + 1, end.hour, end.minute);
    }

    if (!end.isAfter(earliest)) continue;

    final containsNow = !now.isBefore(start) && now.isBefore(end);
    final isCurrentDay = containsNow || _isSameDay(start, today);

    if (isCurrentDay && goalReachedToday) continue;

    final drankInWindow = lastDrinkAt != null &&
        !lastDrinkAt.isBefore(start) &&
        lastDrinkAt.isBefore(end);
    var next = (drankInWindow ? lastDrinkAt : start).add(interval);

    if (next.isBefore(earliest)) {
      final behind = earliest.difference(next).inMicroseconds;
      final steps = (behind / interval.inMicroseconds).ceil();
      next = next.add(interval * steps);
    }

    while (next.isBefore(end)) {
      slots.add(ReminderSlot(next, isCurrentDay: isCurrentDay));
      if (slots.length >= maxCount) return slots;
      next = next.add(interval);
    }
  }

  return slots;
}

DateTime _at(DateTime day, String hhmm) {
  final parts = hhmm.split(':');
  final hour = int.tryParse(parts.first) ?? 8;
  final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  return DateTime(day.year, day.month, day.day, hour.clamp(0, 23), minute.clamp(0, 59));
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
