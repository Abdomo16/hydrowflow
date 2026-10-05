import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/notifications/notification_service.dart';
import 'package:hydrowflow/features/reminders/data/models/reminder_settings.dart';
import '../data/repositories/reminder_repository.dart';
import 'reminder_coordinator.dart';
import 'reminder_state.dart';

class ReminderCubit extends Cubit<ReminderState> {
  final ReminderRepository repository;
  final ReminderCoordinator coordinator;

  ReminderCubit(this.repository, this.coordinator)
    : super(ReminderState.initial()) {
    coordinator.status.addListener(_onStatusChanged);
    load();
  }

  void _onStatusChanged() {
    if (!isClosed) emit(state.copyWith(status: coordinator.status.value));
  }

  Future<void> load() async {
    final settings = await repository.getSettings();
    final allowed = await NotificationService.areNotificationsEnabled();

    emit(
      state.copyWith(
        settings: settings,
        loading: false,
        permissionDenied: settings.enabled && !allowed,
        status: coordinator.status.value,
      ),
    );
  }

  /// Re-checks permission, e.g. after the user returns from system settings.
  Future<void> refreshPermission() async {
    final allowed = await NotificationService.areNotificationsEnabled();
    emit(state.copyWith(permissionDenied: state.settings.enabled && !allowed));
  }

  Future<void> toggle(bool value) async {
    if (value) {
      final granted = await NotificationService.requestPermission() ||
          await NotificationService.areNotificationsEnabled();
      if (!granted) {
        emit(state.copyWith(permissionDenied: true));
        return;
      }
    }

    emit(state.copyWith(permissionDenied: false));
    await updateSettings(state.settings.copyWith(enabled: value));
  }

  Future<void> updateSettings(ReminderSettings updated) async {
    await repository.saveSettings(updated);
    emit(state.copyWith(settings: updated));
    await coordinator.reschedule();
  }

  Future<void> changeFrequency(int minutes) =>
      updateSettings(state.settings.copyWith(frequencyMinutes: minutes));

  Future<void> changeWakeTime(String time) =>
      updateSettings(state.settings.copyWith(wakeTime: time));

  Future<void> changeSleepTime(String time) =>
      updateSettings(state.settings.copyWith(sleepTime: time));

  Future<void> changeSound(String sound) =>
      updateSettings(state.settings.copyWith(sound: sound));

  Future<bool> _ensurePermission() async {
    final allowed = await NotificationService.areNotificationsEnabled() ||
        await NotificationService.requestPermission();
    if (!allowed) emit(state.copyWith(permissionDenied: true));
    return allowed;
  }

  Future<bool> previewSound(String soundId) async {
    if (!await _ensurePermission()) return false;
    return NotificationService.showNow(
      title: 'Sound preview',
      body: 'This is how your reminders will sound.',
      soundId: soundId,
    );
  }

  Future<bool> sendTest() async {
    if (!await _ensurePermission()) return false;
    return NotificationService.showNow(
      title: 'Time for a sip 💧',
      body: 'Test notification: reminders are working.',
      soundId: state.settings.sound,
    );
  }

  @override
  Future<void> close() {
    coordinator.status.removeListener(_onStatusChanged);
    return super.close();
  }
}
