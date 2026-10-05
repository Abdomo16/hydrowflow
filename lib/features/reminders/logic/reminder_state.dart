import '../data/models/reminder_settings.dart';
import '../data/models/reminder_sound.dart';
import 'reminder_coordinator.dart';

class ReminderState {
  final ReminderSettings settings;
  final bool loading;
  final bool permissionDenied;
  final ReminderStatus status;

  const ReminderState({
    required this.settings,
    required this.loading,
    this.permissionDenied = false,
    this.status = ReminderStatus.disabled,
  });

  factory ReminderState.initial() {
    return const ReminderState(
      loading: true,
      settings: ReminderSettings(
        enabled: false,
        frequencyMinutes: 60,
        wakeTime: '08:00',
        sleepTime: '22:30',
        sound: ReminderSound.systemDefaultId,
      ),
    );
  }

  ReminderState copyWith({
    ReminderSettings? settings,
    bool? loading,
    bool? permissionDenied,
    ReminderStatus? status,
  }) {
    return ReminderState(
      settings: settings ?? this.settings,
      loading: loading ?? this.loading,
      permissionDenied: permissionDenied ?? this.permissionDenied,
      status: status ?? this.status,
    );
  }
}
