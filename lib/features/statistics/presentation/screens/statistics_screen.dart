import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFF0E1621),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1621),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Statistics & Streaks',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<StatisticsCubit, StatisticsState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2F8BEF)),
            );
          }

          final isWeek = state.view == StatsView.week;

          return RefreshIndicator(
            onRefresh: () => context.read<StatisticsCubit>().refresh(),
            color: const Color(0xFF2F8BEF),
            backgroundColor: const Color(0xFF16202A),
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
                    title: isWeek ? 'Weekly Progress' : 'Monthly Progress',
                    cups: isWeek ? state.weeklyCups : state.monthlyCups,
                    labels: isWeek
                        ? const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                        : const ['W1', 'W2', 'W3', 'W4'],
                    spread: !isWeek,
                  ),
                  const SizedBox(height: 24),

                  MonthlyOverview(
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
