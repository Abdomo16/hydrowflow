import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/features/settings/data/models/settings_model.dart';
import 'package:hydrowflow/features/settings/data/repositories/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository repository;

  SettingsCubit(this.repository) : super(SettingsState.initial()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    final settings = await repository.load();
    emit(state.copyWith(settings: settings, loading: false));
  }

  Future<void> setUnit(AppUnit unit) async {
    final updated = state.settings.copyWith(unit: unit);
    await _save(updated);
  }

  Future<void> toggleDarkMode(bool value) async {
    final updated = state.settings.copyWith(darkMode: value);
    await _save(updated);
  }

  Future<void> _save(SettingsModel settings) async {
    await repository.save(settings);
    emit(state.copyWith(settings: settings));
  }
}
