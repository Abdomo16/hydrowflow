import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/notifications/notification_loop.dart';
import 'package:hydrowflow/core/notifications/notification_service.dart';
import 'package:hydrowflow/features/hydration/data/hydration_repository.dart';
import 'package:hydrowflow/features/onboarding/data/repositories/user_profile_repository.dart';
import 'package:hydrowflow/features/reminders/data/models/reminder_settings.dart';
import '../data/repositories/reminder_repository.dart';
import 'reminder_state.dart';

class ReminderCubit extends Cubit<ReminderState> {
  final ReminderRepository repository;
  final HydrationRepository hydrationRepository;
  final UserProfileRepository userProfileRepository;

  ReminderCubit(
    this.repository,
    this.hydrationRepository,
    this.userProfileRepository,
  ) : super(ReminderState.initial()) {
    load();
  }

  Future<void> load() async {
    final settings = await repository.getSettings();
    emit(state.copyWith(settings: settings, loading: false));

    if (!settings.enabled) return;

    await _restartNotifications(settings);
  }

  Future<void> toggle(bool value) async {
    final updated = state.settings.copyWith(enabled: value);
    await repository.saveSettings(updated);

    emit(state.copyWith(settings: updated));

    if (value) {
      await _restartNotifications(updated);
    } else {
      await NotificationService.cancelAll();
    }
  }

  Future<void> updateSettings(ReminderSettings updated) async {
    await repository.saveSettings(updated);
    emit(state.copyWith(settings: updated));

    if (updated.enabled) {
      await _restartNotifications(updated);
    }
  }

  Future<void> changeFrequency(int minutes) async {
    await updateSettings(state.settings.copyWith(frequencyMinutes: minutes));
  }

  Future<void> changeWakeTime(String time) async {
    await updateSettings(state.settings.copyWith(wakeTime: time));
  }

  Future<void> changeSleepTime(String time) async {
    await updateSettings(state.settings.copyWith(sleepTime: time));
  }

  Future<void> changeSound(String sound) async {
    await updateSettings(state.settings.copyWith(sound: sound));
  }

  Future<void> _restartNotifications(ReminderSettings settings) async {
    await NotificationService.cancelAll();

    final todayCups = await hydrationRepository.getTodayCups();
    final profile = await userProfileRepository.getProfile();

    if (profile == null) return;

    final dailyGoalLiters = (profile['daily_goal'] as num).toDouble();
    final totalCups = (dailyGoalLiters * 1000 / 250).round();

    if (todayCups >= totalCups) return;

    await NotificationLoop.start(
      frequencyMinutes: settings.frequencyMinutes,
      wake: settings.wakeTime,
      sleep: settings.sleepTime,
      sound: settings.sound,
      daysAhead: 30,
    );
  }
}
