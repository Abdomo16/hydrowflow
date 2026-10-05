import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/di/service_locator.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import 'package:hydrowflow/features/settings/data/models/settings_model.dart';
import 'package:hydrowflow/features/settings/data/repositories/settings_repository.dart';
import 'package:hydrowflow/features/settings/logic/settings_cubit.dart';
import 'package:hydrowflow/features/settings/logic/settings_state.dart';
import 'package:hydrowflow/database/app_database.dart';
import 'package:hydrowflow/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:hydrowflow/features/subscription/data/repositories/subscription_repository.dart';
import 'package:hydrowflow/core/navigation/main_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupLocator();

  try {
    await Firebase.initializeApp();
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  } catch (e, stack) {
    log('Firebase initialization skipped or failed: $e', stackTrace: stack);
  }

  try {
    await locator<SubscriptionRepository>().initialize();
  } catch (e) {
    log('RevenueCat initialization skipped or failed: $e');
  }

  final settings = await locator<SettingsRepository>().load();

  runApp(MyApp(initialSettings: settings));
}

class MyApp extends StatelessWidget {
  final SettingsModel initialSettings;

  const MyApp({super.key, required this.initialSettings});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(
        locator<SettingsRepository>(),
        initial: initialSettings,
      ),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (prev, curr) =>
            prev.settings.darkMode != curr.settings.darkMode,
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'HydroFlow',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state.settings.darkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const AppStarter(),
          );
        },
      ),
    );
  }
}

class AppStarter extends StatefulWidget {
  const AppStarter({super.key});

  @override
  State<AppStarter> createState() => _AppStarterState();
}

class _AppStarterState extends State<AppStarter> {
  bool? onboardingDone;
  double? dailyGoal;

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  Future<void> checkUser() async {
    final db = await AppDatabase.database;

    final result = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (result.isEmpty || result.first['onboarding_done'] != 1) {
      setState(() => onboardingDone = false);
    } else {
      dailyGoal = (result.first['daily_goal'] as num).toDouble();
      setState(() => onboardingDone = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (onboardingDone == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!onboardingDone!) {
      return const OnboardingScreen();
    }

    // Sign-in is optional (store policy: don't gate core features).
    // Users can sign in from Settings > Account to sync data and
    // recover purchases.
    return MainNavigation(dailyGoal: dailyGoal!);
  }
}
