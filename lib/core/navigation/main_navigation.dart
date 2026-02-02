import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/hydration/presentation/screens/hydration_screen.dart';
import '../../features/reminders/presentation/screens/reminder_screen.dart';

import 'bottom_nav_bar.dart';
import 'logic/navigation_cubit.dart';
import 'logic/navigation_state.dart';

// TEMP screens (replace later)
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Stats', style: TextStyle(color: Colors.white)),
    );
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Account / Setup', style: TextStyle(color: Colors.white)),
    );
  }
}

class MainNavigation extends StatelessWidget {
  final double dailyGoal;

  const MainNavigation({super.key, required this.dailyGoal});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationCubit(),
      child: BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, state) {
          final pages = [
            HydrationScreen(dailyGoal: dailyGoal),
            const StatsScreen(),
            const ReminderScreen(),
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
