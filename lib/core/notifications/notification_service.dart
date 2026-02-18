import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _baseChannelName = 'Hydration Reminders';
  static const String _channelDescription =
      'Reminds you to drink water during the day';

  static final Set<String> _createdChannels = {};

  /// Initialize notifications
  static Future<void> init() async {
    // Initialize timezone database
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    }

    if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  /// Create Android channel dynamically per sound
  static Future<void> _createChannelForSound(String sound) async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    final safeSound = sound.isEmpty ? "default" : sound;
    final channelId = 'hydration_$safeSound';

    if (_createdChannels.contains(channelId)) return;

    final channel = AndroidNotificationChannel(
      channelId,
      '$_baseChannelName ($safeSound)',
      description: _channelDescription,
      importance: Importance.max,
      playSound: true,
      sound: safeSound == "default"
          ? null
          : RawResourceAndroidNotificationSound(safeSound),
    );

    await androidPlugin.createNotificationChannel(channel);
    _createdChannels.add(channelId);
  }

  /// Schedule notification
  static Future<void> schedule({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
    required String sound,
  }) async {
    await _createChannelForSound(sound);

    final safeSound = sound.isEmpty ? "default" : sound;

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'hydration_$safeSound',
          '$_baseChannelName ($safeSound)',
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: safeSound == "default"
              ? null
              : RawResourceAndroidNotificationSound(safeSound),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          sound: safeSound == "default" ? null : '$safeSound.aiff',
        ),
      ),
      androidAllowWhileIdle: true,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
