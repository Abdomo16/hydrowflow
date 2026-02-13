import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hydrowflow/core/app/logic/app_cubit.dart';
import 'package:hydrowflow/features/profile/presentation/screens/profile_screen.dart';

import '../../features/hydration/presentation/screens/hydration_screen.dart';
import '../../features/hydration/logic/hydration_cubit.dart';
import '../../features/hydration/data/hydration_repository.dart';

import '../../features/reminders/presentation/screens/reminder_screen.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../../features/statistics/logic/statistics_cubit.dart';
import '../../features/statistics/data/repositories/statistics_repository.dart';

import 'bottom_nav_bar.dart';
import 'logic/navigation_cubit.dart';
import 'logic/navigation_state.dart';
import 'package:hydrowflow/core/notifications/notification_service.dart';

class MainNavigation extends StatefulWidget {
  final double dailyGoal;

  const MainNavigation({super.key, required this.dailyGoal});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  @override
  void initState() {
    super.initState();
    NotificationService.init();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationCubit()),

        BlocProvider(create: (_) => AppCubit(widget.dailyGoal)),

        BlocProvider(
          create: (_) => HydrationCubit(
            dailyGoalLiters: widget.dailyGoal,
            repository: HydrationRepository(),
          ),
        ),

        BlocProvider(
          create: (_) => StatisticsCubit(
            StatisticsRepository(),
            (widget.dailyGoal * 1000 / 250).round(),
          ),
        ),
      ],
      child: BlocListener<AppCubit, double>(
        listener: (context, newGoal) {
          context.read<HydrationCubit>().updateGoal(newGoal);

          context.read<StatisticsCubit>().updateTarget(
            (newGoal * 1000 / 250).round(),
          );
        },
        child: BlocConsumer<NavigationCubit, NavigationState>(
          listener: (context, state) {
            if (state.index == 1) {
              context.read<StatisticsCubit>().load();
            }
          },
          builder: (context, state) {
            final pages = [
              const HydrationScreen(),
              const StatisticsScreen(),
              const ReminderScreen(),
              const ProfileScreen(),
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
      ),
    );
  }
}
