import 'package:hydrowflow/core/notifications/notification_service.dart';

class NotificationLoop {
  static Future<void> start({
    required int frequencyMinutes,
    required String wake,
    required String sleep,
    required String sound,
  }) async {
    await NotificationService.cancelAll();

    final now = DateTime.now();

    final wakeTime = _combine(now, wake);
    DateTime sleepTime = _combine(now, sleep);

    if (sleepTime.isBefore(wakeTime)) {
      sleepTime = sleepTime.add(const Duration(days: 1));
    }

    DateTime current = now.isBefore(wakeTime) ? wakeTime : now;

    // Align first notification to frequency
    final remainder = current.minute % frequencyMinutes;
    if (remainder != 0) {
      current = current.add(Duration(minutes: frequencyMinutes - remainder));
    }

    //  Stable IDs
    int id = 1000;

    while (current.isBefore(sleepTime)) {
      await NotificationService.schedule(
        id: id++,
        dateTime: current,
        title: 'Drink Water 💧',
        body: 'Stay hydrated!',
        sound: sound,
      );

      current = current.add(Duration(minutes: frequencyMinutes));
    }
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
