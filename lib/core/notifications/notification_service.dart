import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hydrowflow/features/reminders/data/models/reminder_sound.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Scheduled reminders use ids [reminderIdStart, reminderIdStart + maxReminders).
  static const int reminderIdStart = 1000;
  static const int maxReminders = 60;
  static const int _instantId = 1;

  static const String _channelPrefix = 'hydration_v2_';
  static const String _channelName = 'Hydration Reminders';
  static const String _channelDescription =
      'Reminds you to drink water during the day';

  static final Set<String> _createdChannels = {};
  static Future<void>? _initFuture;

  static Future<void> init() => _initFuture ??= _init();

  static Future<void> _init() async {
    tz.initializeTimeZones();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _notifications.initialize(settings);
    await _deleteLegacyChannels();
  }

  static AndroidFlutterLocalNotificationsPlugin? get _android =>
      _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  static IOSFlutterLocalNotificationsPlugin? get _ios =>
      _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  /// Asks the user for notification permission. Returns true if granted.
  static Future<bool> requestPermission() async {
    await init();
    try {
      if (Platform.isAndroid) {
        return await _android?.requestNotificationsPermission() ?? false;
      }
      if (Platform.isIOS) {
        return await _ios?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
    } catch (e) {
      debugPrint('NotificationService.requestPermission failed: $e');
    }
    return false;
  }

  static Future<bool> areNotificationsEnabled() async {
    await init();
    try {
      if (Platform.isAndroid) {
        return await _android?.areNotificationsEnabled() ?? false;
      }
      if (Platform.isIOS) {
        final options = await _ios?.checkPermissions();
        return options?.isEnabled ?? false;
      }
    } catch (e) {
      debugPrint('NotificationService.areNotificationsEnabled failed: $e');
    }
    return false;
  }

  /// Schedules one reminder. Returns false if the platform rejected it.
  static Future<bool> schedule({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
    required String soundId,
  }) async {
    await init();
    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(dateTime, tz.local),
        await _details(soundId),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      return true;
    } catch (e) {
      debugPrint('NotificationService.schedule($id at $dateTime) failed: $e');
      return false;
    }
  }

  /// Shows a notification immediately (used for test and sound preview).
  static Future<bool> showNow({
    required String title,
    required String body,
    required String soundId,
  }) async {
    await init();
    try {
      await _notifications.show(
        _instantId,
        title,
        body,
        await _details(soundId),
      );
      return true;
    } catch (e) {
      debugPrint('NotificationService.showNow failed: $e');
      return false;
    }
  }

  static Future<void> cancelReminders() async {
    await init();
    try {
      final pending = await _notifications.pendingNotificationRequests();
      for (final request in pending) {
        if (request.id >= reminderIdStart &&
            request.id < reminderIdStart + maxReminders) {
          await _notifications.cancel(request.id);
        }
      }
    } catch (e) {
      debugPrint('NotificationService.cancelReminders failed: $e');
    }
  }

  static Future<NotificationDetails> _details(String soundId) async {
    final sound = ReminderSound.byId(soundId);
    final channelId = '$_channelPrefix${sound.id}';
    final androidSound = sound.androidResource == null
        ? null
        : RawResourceAndroidNotificationSound(sound.androidResource);

    if (Platform.isAndroid && !_createdChannels.contains(channelId)) {
      await _android?.createNotificationChannel(
        AndroidNotificationChannel(
          channelId,
          '$_channelName (${sound.label})',
          description: _channelDescription,
          importance: Importance.high,
          playSound: true,
          sound: androidSound,
        ),
      );
      _createdChannels.add(channelId);
    }

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        '$_channelName (${sound.label})',
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: androidSound,
        category: AndroidNotificationCategory.reminder,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentList: true,
        presentSound: true,
      ),
    );
  }

  /// Channels created by older versions pointed at missing sound files.
  static Future<void> _deleteLegacyChannels() async {
    if (!Platform.isAndroid) return;
    try {
      final channels = await _android?.getNotificationChannels() ?? [];
      for (final channel in channels) {
        if (channel.id.startsWith('hydration_') &&
            !channel.id.startsWith(_channelPrefix)) {
          await _android?.deleteNotificationChannel(channel.id);
        }
      }
    } catch (e) {
      debugPrint('NotificationService legacy channel cleanup failed: $e');
    }
  }
}
