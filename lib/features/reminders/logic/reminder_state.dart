import '../data/models/reminder_settings.dart';

class ReminderState {
  final ReminderSettings settings;
  final bool loading;

  const ReminderState({required this.settings, required this.loading});

  factory ReminderState.initial() {
    return ReminderState(
      loading: true,
      settings: const ReminderSettings(
        enabled: false,
        frequencyMinutes: 60,
        wakeTime: '08:00',
        sleepTime: '22:30',
        sound: 'ultra_minimal_tech_pulse',
      ),
    );
  }

  ReminderState copyWith({ReminderSettings? settings, bool? loading}) {
    return ReminderState(
      settings: settings ?? this.settings,
      loading: loading ?? this.loading,
    );
  }
}
