import 'package:flutter/material.dart';
import 'package:hydrowflow/database/app_database.dart';
import 'package:hydrowflow/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:hydrowflow/core/navigation/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Inter'),
      home: const AppStarter(),
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
      dailyGoal = result.first['daily_goal'] as double;
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

    return MainNavigation(dailyGoal: dailyGoal!);
  }
}
