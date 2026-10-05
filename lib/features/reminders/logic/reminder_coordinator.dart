import 'package:flutter/foundation.dart';
import 'package:hydrowflow/core/notifications/notification_service.dart';
import 'package:hydrowflow/features/hydration/data/hydration_repository.dart';
import 'package:hydrowflow/features/onboarding/data/repositories/user_profile_repository.dart';
import 'package:hydrowflow/features/reminders/data/repositories/reminder_repository.dart';
import 'package:hydrowflow/features/reminders/logic/reminder_scheduler.dart';

class ReminderStatus {
  final bool enabled;
  final bool goalReachedToday;
  final DateTime? nextReminderAt;
  final int scheduledCount;

  const ReminderStatus({
    required this.enabled,
    required this.goalReachedToday,
    this.nextReminderAt,
    this.scheduledCount = 0,
  });

  static const disabled = ReminderStatus(enabled: false, goalReachedToday: false);
}

/// Single entry point for (re)scheduling reminders. Call [reschedule] whenever
/// drinks, the goal, or reminder settings change, and when the app resumes.
class ReminderCoordinator {
  final ReminderRepository reminderRepository;
  final HydrationRepository hydrationRepository;
  final UserProfileRepository userProfileRepository;

  ReminderCoordinator(
    this.reminderRepository,
    this.hydrationRepository,
    this.userProfileRepository,
  );

  Future<ReminderStatus> _pending = Future.value(ReminderStatus.disabled);

  final ValueNotifier<ReminderStatus> status = ValueNotifier(
    ReminderStatus.disabled,
  );

  /// Calls are serialized so rapid drink taps can't interleave cancel/schedule.
  Future<ReminderStatus> reschedule() {
    _pending = _pending
        .catchError((_) => ReminderStatus.disabled)
        .then((_) => _reschedule());
    return _pending;
  }

  Future<ReminderStatus> _reschedule() async {
    try {
      final settings = await reminderRepository.getSettings();
      await NotificationService.cancelReminders();

      if (!settings.enabled) {
        return status.value = ReminderStatus.disabled;
      }

      final profile = await userProfileRepository.getProfile();
      final goalMl = profile == null
          ? 0
          : ((profile['daily_goal'] as num).toDouble() * 1000).round();
      final consumedMl = await hydrationRepository.getTodayMl();
      final lastDrinkAt = await hydrationRepository.getLastLogTime();
      final goalReached = goalMl > 0 && consumedMl >= goalMl;

      final slots = planReminders(
        intervalMinutes: settings.frequencyMinutes,
        wakeTime: settings.wakeTime,
        sleepTime: settings.sleepTime,
        now: DateTime.now(),
        goalReachedToday: goalReached,
        lastDrinkAt: lastDrinkAt,
        maxCount: NotificationService.maxReminders,
      );

      var scheduled = 0;
      for (var i = 0; i < slots.length; i++) {
        final message = _messageFor(
          i,
          slots[i],
          remainingMl: goalMl - consumedMl,
        );
        final ok = await NotificationService.schedule(
          id: NotificationService.reminderIdStart + i,
          dateTime: slots[i].at,
          title: message.$1,
          body: message.$2,
          soundId: settings.sound,
        );
        if (ok) scheduled++;
      }

      return status.value = ReminderStatus(
        enabled: true,
        goalReachedToday: goalReached,
        nextReminderAt: slots.isEmpty ? null : slots.first.at,
        scheduledCount: scheduled,
      );
    } catch (e) {
      debugPrint('ReminderCoordinator.reschedule failed: $e');
      return status.value;
    }
  }

  static const _titles = [
    'Time for a sip 💧',
    'Hydration check 💧',
    'Your body needs water 💧',
    'Quick water break 💧',
  ];

  static const _genericBodies = [
    'A glass of water now keeps you focused and fresh.',
    'Small sips add up. Grab your cup!',
    'Stay on track with your daily goal.',
    'Drinking regularly beats drinking a lot at once.',
  ];

  (String, String) _messageFor(
    int index,
    ReminderSlot slot, {
    required int remainingMl,
  }) {
    final title = _titles[index % _titles.length];

    if (slot.isCurrentDay && remainingMl > 0) {
      return (title, '$remainingMl ml to go to reach today\'s goal.');
    }

    return (title, _genericBodies[index % _genericBodies.length]);
  }
}
