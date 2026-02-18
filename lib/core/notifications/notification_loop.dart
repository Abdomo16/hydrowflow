import 'package:hydrowflow/core/notifications/notification_service.dart';

class NotificationLoop {
  static Future<void> start({
    required int frequencyMinutes,
    required String wake,
    required String sleep,
    required String sound,
    int daysAhead = 14,
  }) async {
    await NotificationService.cancelAll();

    final now = DateTime.now();

    DateTime wakeTime = _combine(now, wake);
    DateTime sleepTime = _combine(now, sleep);

    // Handle sleep after midnight
    if (sleepTime.isBefore(wakeTime)) {
      sleepTime = sleepTime.add(const Duration(days: 1));
    }

    // If today finished  move to tomorrow
    if (now.isAfter(sleepTime)) {
      wakeTime = wakeTime.add(const Duration(days: 1));
      sleepTime = sleepTime.add(const Duration(days: 1));
    }

    int id = 0; // Safe simple ID system
    final List<Future> futures = [];

    for (int day = 0; day < daysAhead; day++) {
      final dayWake = wakeTime.add(Duration(days: day));
      final daySleep = sleepTime.add(Duration(days: day));

      DateTime nextTime = dayWake;

      if (day == 0) {
        while (nextTime.isBefore(now)) {
          nextTime = nextTime.add(Duration(minutes: frequencyMinutes));
        }
      }

      int dailyCount = 0;
      const maxPerDay = 40;

      while (nextTime.isBefore(daySleep)) {
        if (dailyCount >= maxPerDay) break;

        futures.add(
          NotificationService.schedule(
            id: id,
            dateTime: nextTime,
            title: 'Drink Water 💧',
            body: 'Stay hydrated!',
            sound: sound,
          ),
        );

        id++;
        dailyCount++;
        nextTime = nextTime.add(Duration(minutes: frequencyMinutes));
      }
    }

    try {
      await Future.wait(futures, eagerError: false);
    } catch (_) {}
  }

  static DateTime _combine(DateTime base, String time) {
    final parts = time.split(':');

    return DateTime(
      base.year,
      base.month,
      base.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}
