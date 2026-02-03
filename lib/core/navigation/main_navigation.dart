import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/hydration/presentation/screens/hydration_screen.dart';
import '../../features/reminders/presentation/screens/reminder_screen.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';

import 'bottom_nav_bar.dart';
import 'logic/navigation_cubit.dart';
import 'logic/navigation_state.dart';
import 'package:hydrowflow/core/notifications/notification_service.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Account / Setup', style: TextStyle(color: Colors.white)),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final double dailyGoal; // liters

  const MainNavigation({super.key, required this.dailyGoal});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late final int targetCups;

  @override
  void initState() {
    super.initState();

    //  Init notifications
    NotificationService.init();

    // Convert liters → cups (250ml)
    targetCups = (widget.dailyGoal * 1000 / 250).round();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationCubit(),
      child: BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, state) {
          final pages = [
            //  Tracker
            HydrationScreen(dailyGoal: widget.dailyGoal),

            //  REAL STATISTICS PAGE
            StatisticsScreen(targetCups: targetCups),

            //  Reminders
            const ReminderScreen(),

            // Account
            const AccountScreen(),
          ];

          return Scaffold(
            backgroundColor: const Color(0xFF0E1621),

            body: IndexedStack(index: state.index, children: pages),

            bottomNavigationBar: AppBottomNavBar(
              currentIndex: state.index,
              onTap: (i) => context.read<NavigationCubit>().changeTab(i),
            ),
          );
        },
      ),
    );
  }
}
