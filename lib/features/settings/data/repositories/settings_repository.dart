import 'package:hydrowflow/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

class SettingsRepository {
  static const String _unitKey = 'app_unit';
  static const String _darkModeKey = 'dark_mode_v2';
  static const String _cupSizeKey = 'cup_size_ml';
  static const String _paletteKey = 'theme_palette';

  Future<SettingsModel> load() async {
    final prefs = await SharedPreferences.getInstance();

    final unitString = prefs.getString(_unitKey);
    final unit = AppUnit.values.firstWhere(
      (u) => u.name == unitString,
      orElse: () => AppUnit.metric,
    );

    return SettingsModel(
      unit: unit,
      darkMode: prefs.getBool(_darkModeKey) ?? false,
      cupSizeMl: prefs.getInt(_cupSizeKey) ?? SettingsModel.defaultCupSizeMl,
      palette: AppPalette.byName(prefs.getString(_paletteKey)),
    );
  }

  Future<void> save(SettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_unitKey, settings.unit.name);
    await prefs.setBool(_darkModeKey, settings.darkMode);
    await prefs.setInt(_cupSizeKey, settings.cupSizeMl);
    await prefs.setString(_paletteKey, settings.palette.name);
  }
}
