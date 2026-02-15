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

    // Handle sleep after midnight
    if (sleepTime.isBefore(wakeTime)) {
      sleepTime = sleepTime.add(const Duration(days: 1));
    }

    // If now is before wake → schedule at wake
    DateTime nextTime = now.isBefore(wakeTime) ? wakeTime : now;

    // Align next reminder to frequency
    final remainder = nextTime.minute % frequencyMinutes;
    if (remainder != 0) {
      nextTime = nextTime.add(Duration(minutes: frequencyMinutes - remainder));
    }

    // If next reminder is after sleep → do nothing
    if (nextTime.isAfter(sleepTime)) return;

    await NotificationService.schedule(
      id: 1000, // single stable ID
      dateTime: nextTime,
      title: 'Drink Water 💧',
      body: 'Stay hydrated!',
      sound: sound,
    );
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
