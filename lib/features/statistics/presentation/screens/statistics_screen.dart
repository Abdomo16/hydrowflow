import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/statistics_repository.dart';
import '../../logic/statistics_cubit.dart';
import '../../logic/statistics_state.dart';
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

                  WeeklyBarChart(
                    title: isWeek
                        ? 'This Week'
                        : '${DateFormat('MMMM').format(now)} Progress',
                    cups: isWeek ? state.weeklyCups : state.monthlyCups,
                    labels: isWeek
                        ? const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                        : List.generate(
                            state.monthlyCups.length,
                            (i) => 'W${i + 1}',
                          ),
                    highlightIndex: isWeek
                        ? now.weekday - 1
                        : StatisticsRepository.weekOfMonth(now),
                  ),
                  const SizedBox(height: 24),

                  MonthlyOverview(
                    title: '${DateFormat('MMMM').format(now)} Overview',
                    avg: state.avgMonthly,
                    completion: state.completionRate,
                    bestDay: state.bestDay,
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
