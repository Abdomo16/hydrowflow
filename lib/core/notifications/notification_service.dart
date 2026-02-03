import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _baseChannelName = 'Hydration Reminders';
  static const String _channelDescription =
      'Reminds you to drink water during the day';

  /// INIT
  static Future<void> init() async {
    //  Initialize timezones
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    // Android 13+ notification permission
    await androidPlugin.requestNotificationsPermission();

    //  Android 12+ exact alarms (no dialog on Android 13)
    await androidPlugin.requestExactAlarmsPermission();
  }

  /// OPEN EXACT ALARM SETTINGS (ANDROID 12 / 13)
  static Future<void> openExactAlarmSettings() async {
    if (!Platform.isAndroid) return;

    // Official Android intent
    const intent = 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM';

    final uri = Uri.parse(intent);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// CREATE CHANNEL PER SOUND
  static Future<void> _createChannelForSound(String sound) async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    final channelId = 'hydration_${sound}_v2';

    final channel = AndroidNotificationChannel(
      channelId,
      '$_baseChannelName ($sound)',
      description: _channelDescription,
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(sound),
    );

    await androidPlugin.createNotificationChannel(channel);
  }

  /// SCHEDULE NOTIFICATION
  static Future<void> schedule({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
    required String sound,
  }) async {
    await _createChannelForSound(sound);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'hydration_${sound}_v2',
          '$_baseChannelName ($sound)',
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(sound),
        ),
      ),
      androidAllowWhileIdle: true,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
