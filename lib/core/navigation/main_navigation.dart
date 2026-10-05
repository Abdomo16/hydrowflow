import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hydrowflow/core/ads/banner_ad_bar.dart';
import 'package:hydrowflow/core/ads/daily_interstitial.dart';
import 'package:hydrowflow/core/app/logic/app_cubit.dart';
import 'package:hydrowflow/core/di/service_locator.dart';

import '../../features/hydration/data/hydration_repository.dart';
import '../../features/hydration/logic/hydration_cubit.dart';
import '../../features/hydration/presentation/screens/hydration_screen.dart';

import '../../features/reminders/logic/reminder_coordinator.dart';
import '../../features/reminders/presentation/screens/reminder_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/statistics/data/repositories/statistics_repository.dart';
import '../../features/statistics/logic/statistics_cubit.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../../features/subscription/logic/subscription_cubit.dart';
import '../../features/subscription/logic/subscription_state.dart';
import '../../features/widget/widget_service.dart';

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

class _MainNavigationState extends State<MainNavigation>
    with WidgetsBindingObserver {
  final _reminders = locator<ReminderCoordinator>();
  final _subscription = locator<SubscriptionCubit>();
  late final HydrationCubit _hydration;

  @override
  void initState() {
    super.initState();
    _hydration = HydrationCubit(
      dailyGoalLiters: widget.dailyGoal,
      repository: locator<HydrationRepository>(),
      onLogsChanged: _onLogsChanged,
      onGoalReached: _onGoalReached,
    );
    WidgetsBinding.instance.addObserver(this);
    NotificationService.init().then((_) => _reminders.reschedule());
    WidgetService.init().then((_) => _refreshWidget());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hydration.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _subscription.checkTrialExpiry();
      // Drinks may have been added from the home screen widget.
      _hydration.loadToday();
      _reminders.reschedule();
      _refreshWidget();
      if (!_subscription.state.isPremium) DailyInterstitial.preload();
    }
  }

  Future<void> _refreshWidget() =>
      WidgetService.refresh(premium: _subscription.state.isPremium);

  Future<void> _onLogsChanged() async {
    await _reminders.reschedule();
    await _refreshWidget();
  }

  void _onGoalReached() {
    if (_subscription.state.isPremium) return;
    DailyInterstitial.maybeShow();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationCubit()),

        BlocProvider(create: (_) => AppCubit(widget.dailyGoal)),

        BlocProvider.value(value: _hydration),

        BlocProvider(
          create: (_) => StatisticsCubit(
            locator<StatisticsRepository>(),
            (widget.dailyGoal * 1000 / 250).round(),
          ),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AppCubit, double>(
            listener: (context, newGoal) {
              context.read<HydrationCubit>().updateGoal(newGoal);
              _reminders.reschedule();
              _refreshWidget();

              context.read<StatisticsCubit>().updateTarget(
                (newGoal * 1000 / 250).round(),
              );
            },
          ),
          BlocListener<SubscriptionCubit, SubscriptionState>(
            listenWhen: (prev, curr) => prev.isPremium != curr.isPremium,
            listener: (context, state) {
              _reminders.reschedule();
              _refreshWidget();
              if (!state.isPremium) DailyInterstitial.preload();
            },
          ),
        ],
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
              const SettingsScreen(),
            ];

            return Scaffold(
              body: IndexedStack(index: state.index, children: pages),
              bottomNavigationBar: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BannerAdBar(),
                  AppBottomNavBar(
                    currentIndex: state.index,
                    onTap: (i) => context.read<NavigationCubit>().changeTab(i),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
