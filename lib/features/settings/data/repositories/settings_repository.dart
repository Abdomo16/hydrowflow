import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

class SettingsRepository {
  static const String _unitKey = 'app_unit';
  static const String _darkModeKey = 'dark_mode';

  Future<SettingsModel> load() async {
    final prefs = await SharedPreferences.getInstance();

    final unitString = prefs.getString(_unitKey);
    final unit = AppUnit.values.firstWhere(
      (u) => u.name == unitString,
      orElse: () => AppUnit.metric,
    );

    return SettingsModel(
      unit: unit,
      darkMode: prefs.getBool(_darkModeKey) ?? true,
    );
  }

  Future<void> save(SettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_unitKey, settings.unit.name);
    await prefs.setBool(_darkModeKey, settings.darkMode);
  }
}
