import 'package:hydrowflow/features/settings/data/models/settings_model.dart';

class SettingsState {
  final SettingsModel settings;
  final bool loading;

  const SettingsState({required this.settings, this.loading = false});

  factory SettingsState.initial() {
    return SettingsState(settings: SettingsModel.defaults());
  }

  SettingsState copyWith({SettingsModel? settings, bool? loading}) {
    return SettingsState(
      settings: settings ?? this.settings,
      loading: loading ?? this.loading,
    );
  }
}
