import 'package:flutter_test/flutter_test.dart';
import 'package:hydrowflow/features/settings/data/models/settings_model.dart';
import 'package:hydrowflow/features/settings/data/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsRepository', () {
    late SettingsRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = SettingsRepository();
    });

    test('returns defaults when preferences are empty', () async {
      final settings = await repository.load();

      expect(settings.unit, AppUnit.metric);
      expect(settings.darkMode, false);
      expect(settings.cupSizeMl, SettingsModel.defaultCupSizeMl);
    });

    test('persists and reloads settings', () async {
      await repository.save(
        const SettingsModel(
          unit: AppUnit.imperial,
          darkMode: true,
          cupSizeMl: 330,
        ),
      );

      final settings = await repository.load();

      expect(settings.unit, AppUnit.imperial);
      expect(settings.darkMode, true);
      expect(settings.cupSizeMl, 330);
    });
  });
}
