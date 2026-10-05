import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';
import 'package:hydrowflow/features/hydration/data/hydration_repository.dart';
import 'package:hydrowflow/features/onboarding/data/repositories/user_profile_repository.dart';
import 'package:hydrowflow/features/settings/data/repositories/settings_repository.dart';

/// Keeps the Android home screen widget in sync. The widget is Premium:
/// free users see an "unlock" message instead of their progress.
class WidgetService {
  static const String _androidProvider = 'HydroWidgetProvider';
  static const String _premiumKey = 'premium';

  static bool get isSupported => !kIsWeb && Platform.isAndroid;

  static Future<void> init() async {
    if (!isSupported) return;
    try {
      await HomeWidget.registerInteractivityCallback(widgetBackgroundCallback);
    } catch (e) {
      debugPrint('WidgetService.init failed: $e');
    }
  }

  /// Pushes today's progress to the widget. Pass [premium] when it's known;
  /// otherwise the last saved value is reused (e.g. from the widget itself).
  static Future<void> refresh({bool? premium}) async {
    if (!isSupported) return;
    try {
      final isPremium = premium ??
          await HomeWidget.getWidgetData<bool>(_premiumKey) ??
          false;

      final consumedMl = await HydrationRepository().getTodayMl();
      final profile = await UserProfileRepository().getProfile();
      final goalMl = profile == null
          ? 0
          : ((profile['daily_goal'] as num).toDouble() * 1000).round();
      final cupMl = (await SettingsRepository().load()).cupSizeMl;

      await HomeWidget.saveWidgetData<bool>(_premiumKey, isPremium);
      await HomeWidget.saveWidgetData<int>('consumed_ml', consumedMl);
      await HomeWidget.saveWidgetData<int>('goal_ml', goalMl);
      await HomeWidget.saveWidgetData<int>('cup_ml', cupMl);
      await HomeWidget.updateWidget(androidName: _androidProvider);
    } catch (e) {
      debugPrint('WidgetService.refresh failed: $e');
    }
  }
}

/// Runs in a background isolate when the widget's "+ cup" button is tapped.
@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  if (uri?.host != 'addcup') return;
  WidgetsFlutterBinding.ensureInitialized();

  final premium = await HomeWidget.getWidgetData<bool>('premium') ?? false;
  if (!premium) return;

  final cupMl = (await SettingsRepository().load()).cupSizeMl;
  await HydrationRepository().addDrink(cupMl);
  await WidgetService.refresh(premium: true);
}
