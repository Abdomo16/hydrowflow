class ReminderSettings {
  final bool enabled;
  final int frequencyMinutes;
  final String wakeTime;
  final String sleepTime;
  final String sound; 

  const ReminderSettings({
    required this.enabled,
    required this.frequencyMinutes,
    required this.wakeTime,
    required this.sleepTime,
    required this.sound,
  });

  ReminderSettings copyWith({
    bool? enabled,
    int? frequencyMinutes,
    String? wakeTime,
    String? sleepTime,
    String? sound,
  }) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      frequencyMinutes: frequencyMinutes ?? this.frequencyMinutes,
      wakeTime: wakeTime ?? this.wakeTime,
      sleepTime: sleepTime ?? this.sleepTime,
      sound: sound ?? this.sound,
    );
  }
}
