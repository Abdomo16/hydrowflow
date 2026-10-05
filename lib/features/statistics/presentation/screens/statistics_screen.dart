import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import 'package:hydrowflow/features/subscription/logic/pro_gate.dart';
import 'package:hydrowflow/features/subscription/logic/subscription_cubit.dart';
import 'package:hydrowflow/features/subscription/presentation/widgets/premium_lock.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/statistics_repository.dart';
import '../../logic/statistics_cubit.dart';
import '../../logic/statistics_state.dart';
import 'history_screen.dart';
import '../widgets/hydration_score_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/weekly_bar_chart.dart';
import '../widgets/monthly_overview.dart';
import '../widgets/week_month_toggle.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics & Streaks')),
      body: BlocBuilder<StatisticsCubit, StatisticsState>(
        builder: (context, state) {
          if (!state.hasLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final isWeek = state.view == StatsView.week;
          final now = DateTime.now();

          return RefreshIndicator(
            onRefresh: () => context.read<StatisticsCubit>().refresh(),
            color: colors.primary,
            backgroundColor: colors.surface,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  HydrationScoreCard(score: state.hydrationScore),
                  const SizedBox(height: 16),

                  StreakCard(streak: state.streak),
                  const SizedBox(height: 24),

                  const WeekMonthToggle(),
                  const SizedBox(height: 20),

                  if (isWeek)
                    WeeklyBarChart(
                      title: 'This Week',
                      cups: state.weeklyCups,
                      labels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
                      highlightIndex: now.weekday - 1,
                    )
                  else
                    PremiumLock(
                      message: 'See every week of the month with Premium.',
                      child: WeeklyBarChart(
                        title: '${DateFormat('MMMM').format(now)} Progress',
                        cups: state.monthlyCups,
                        labels: List.generate(
                          state.monthlyCups.length,
                          (i) => 'W${i + 1}',
                        ),
                        highlightIndex: StatisticsRepository.weekOfMonth(now),
                      ),
                    ),
                  const SizedBox(height: 24),

                  PremiumLock(
                    message: 'Monthly averages and your best day are Premium.',
                    child: MonthlyOverview(
                      title: '${DateFormat('MMMM').format(now)} Overview',
                      avg: state.avgMonthly,
                      completion: state.completionRate,
                      bestDay: state.bestDay,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _HistoryButton(
                    targetCups: context.read<StatisticsCubit>().targetCups,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HistoryButton extends StatelessWidget {
  final int targetCups;

  const _HistoryButton({required this.targetCups});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final premium = context.select<SubscriptionCubit, bool>(
      (c) => c.state.isPremium,
    );

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () async {
          final navigator = Navigator.of(context);
          if (!await ProGate.showPaywallIfLocked(context)) return;
          navigator.push(
            MaterialPageRoute(
              builder: (_) => HistoryScreen(targetCups: targetCups),
            ),
          );
        },
        icon: Icon(Icons.history, color: colors.primary),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'View full history',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!premium) ...[const SizedBox(width: 8), const ProBadge()],
          ],
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
