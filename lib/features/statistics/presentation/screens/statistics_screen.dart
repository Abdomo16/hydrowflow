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
        centerTitle: true,
        title: const Text(
          'Statistics & Streaks',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.share, color: Colors.white54, size: 18),
          ),
        ],
      ),

      body: BlocBuilder<StatisticsCubit, StatisticsState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final isWeek = state.view == StatsView.week;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                /// Hydration score (same card – different meaning)
                HydrationScoreCard(score: state.hydrationScore),
                const SizedBox(height: 16),

                ///  Streak (always visible)
                StreakCard(streak: state.streak),
                const SizedBox(height: 24),

                ///  Week / Month toggle
                const WeekMonthToggle(),
                const SizedBox(height: 20),

                ///  Progress (Weekly OR Monthly – SAME CARD)
                WeeklyBarChart(
                  title: isWeek ? 'Weekly Progress' : 'Monthly Progress',
                  cups: isWeek ? state.weeklyCups : state.monthlyCups,
                  labels: isWeek
                      ? const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                      : const ['W1', 'W2', 'W3', 'W4'],
                ),
                const SizedBox(height: 24),

                ///  Monthly overview (ALWAYS visible – like design)
                MonthlyOverview(
                  avg: state.avgMonthly,
                  completion: state.completionRate,
                  bestDay: state.bestDay,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
