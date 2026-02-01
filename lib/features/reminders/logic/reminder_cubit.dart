import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/notifications/notification_service.dart';
import 'package:hydrowflow/core/notifications/notification_loop.dart';
import '../data/repositories/reminder_repository.dart';
import 'reminder_state.dart';

class ReminderCubit extends Cubit<ReminderState> {
  final ReminderRepository repository;

  ReminderCubit(this.repository) : super(ReminderState.initial()) {
    load();
  }

  Future<void> load() async {
    final settings = await repository.getSettings();

    if (settings.enabled) {
      await _restartNotifications(settings);
    }

    emit(state.copyWith(settings: settings, loading: false));
  }

  Future<void> toggle(bool value) async {
    final updated = state.settings.copyWith(enabled: value);
    await repository.saveSettings(updated);

    if (value) {
      await _restartNotifications(updated);
    } else {
      await NotificationService.cancelAll();
    }

    emit(state.copyWith(settings: updated));
  }

  Future<void> changeFrequency(int minutes) async {
    final updated = state.settings.copyWith(frequencyMinutes: minutes);
    await repository.saveSettings(updated);

    if (updated.enabled) {
      await _restartNotifications(updated);
    }

    emit(state.copyWith(settings: updated));
  }

  Future<void> changeWakeTime(String time) async {
    final updated = state.settings.copyWith(wakeTime: time);
    await repository.saveSettings(updated);

    if (updated.enabled) {
      await _restartNotifications(updated);
    }

    emit(state.copyWith(settings: updated));
  }

  Future<void> changeSleepTime(String time) async {
    final updated = state.settings.copyWith(sleepTime: time);
    await repository.saveSettings(updated);

    if (updated.enabled) {
      await _restartNotifications(updated);
    }

    emit(state.copyWith(settings: updated));
  }

  Future<void> changeSound(String sound) async {
    final updated = state.settings.copyWith(sound: sound);
    await repository.saveSettings(updated);

    if (updated.enabled) {
      await _restartNotifications(updated);
    }

    emit(state.copyWith(settings: updated));
  }

  // DRY helper
  Future<void> _restartNotifications(settings) async {
    await NotificationLoop.start(
      frequencyMinutes: settings.frequencyMinutes,
      wake: settings.wakeTime,
      sleep: settings.sleepTime,
      sound: settings.sound,
    );
  }
}
