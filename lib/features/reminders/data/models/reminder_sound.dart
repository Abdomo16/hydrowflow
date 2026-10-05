import 'dart:io';

class ReminderSound {
  static const String systemDefaultId = 'default';

  final String id;
  final String label;

  /// Android raw resource name (file in android/app/src/main/res/raw without
  /// extension). Null means the phone's default notification sound.
  final String? androidResource;

  const ReminderSound({
    required this.id,
    required this.label,
    this.androidResource,
  });

  bool get isSystemDefault => androidResource == null;

  static const List<ReminderSound> all = [
    ReminderSound(id: systemDefaultId, label: 'System default'),
    ReminderSound(
      id: 'electric_minimal_ping',
      label: 'Minimal Ping',
      androidResource: 'electric_minimal_ping',
    ),
  ];

  /// Custom sounds are bundled for Android only; iOS always uses the default.
  static List<ReminderSound> get available =>
      Platform.isAndroid ? all : all.where((s) => s.isSystemDefault).toList();

  static ReminderSound byId(String? id) {
    return available.firstWhere(
      (s) => s.id == id,
      orElse: () => all.first,
    );
  }
}
