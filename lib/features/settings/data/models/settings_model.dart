enum AppUnit { metric, imperial }

class SettingsModel {
  static const int defaultCupSizeMl = 250;
  static const List<int> cupSizePresetsMl = [150, 200, 250, 330, 500];

  final AppUnit unit;
  final bool darkMode;
  final int cupSizeMl;

  const SettingsModel({
    required this.unit,
    required this.darkMode,
    this.cupSizeMl = defaultCupSizeMl,
  });

  factory SettingsModel.defaults() {
    return const SettingsModel(unit: AppUnit.metric, darkMode: false);
  }

  SettingsModel copyWith({AppUnit? unit, bool? darkMode, int? cupSizeMl}) {
    return SettingsModel(
      unit: unit ?? this.unit,
      darkMode: darkMode ?? this.darkMode,
      cupSizeMl: cupSizeMl ?? this.cupSizeMl,
    );
  }
}
