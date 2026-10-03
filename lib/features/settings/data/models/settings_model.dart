enum AppUnit { metric, imperial }

class SettingsModel {
  final AppUnit unit;
  final bool darkMode;

  const SettingsModel({required this.unit, required this.darkMode});

  factory SettingsModel.defaults() {
    return const SettingsModel(unit: AppUnit.metric, darkMode: true);
  }

  SettingsModel copyWith({AppUnit? unit, bool? darkMode}) {
    return SettingsModel(
      unit: unit ?? this.unit,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}
