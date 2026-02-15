import 'package:hydrowflow/database/app_database.dart';
import 'package:hydrowflow/features/reminders/data/models/reminder_settings.dart';
import 'package:sqflite/sqflite.dart';

class ReminderRepository {
  Future<ReminderSettings> getSettings() async {
    final db = await AppDatabase.database;

    final result = await db.query('reminder_settings', where: 'id = 1');

    if (result.isEmpty) {
      final defaultSettings = ReminderSettings(
        enabled: false,
        frequencyMinutes: 60,
        wakeTime: '08:00',
        sleepTime: '22:30',
        sound: 'electric_water_flow',
      );

      await saveSettings(defaultSettings);
      return defaultSettings;
    }

    final row = result.first;

    return ReminderSettings(
      enabled: row['enabled'] == 1,
      frequencyMinutes: row['frequency_minutes'] as int,
      wakeTime: row['wake_time'] as String,
      sleepTime: row['sleep_time'] as String,
      sound: row['sound'] as String? ?? 'electric_water_flow',
    );
  }

  Future<void> saveSettings(ReminderSettings settings) async {
    final db = await AppDatabase.database;

    await db.insert('reminder_settings', {
      'id': 1,
      'enabled': settings.enabled ? 1 : 0,
      'frequency_minutes': settings.frequencyMinutes,
      'wake_time': settings.wakeTime,
      'sleep_time': settings.sleepTime,
      'sound': settings.sound,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
