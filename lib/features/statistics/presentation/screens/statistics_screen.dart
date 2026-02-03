import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/features/statistics/data/repositories/statistics_repository.dart';
import '../../logic/statistics_cubit.dart';
import '../../logic/statistics_state.dart';
import '../widgets/hydration_score_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/weekly_bar_chart.dart';
import '../widgets/monthly_overview.dart';

class StatisticsScreen extends StatelessWidget {
  final int targetCups;

  const StatisticsScreen({super.key, required this.targetCups});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StatisticsCubit(StatisticsRepository(), targetCups),
      child: Scaffold(
        backgroundColor: const Color(0xFF0E1621),
        appBar: AppBar(
          title: const Text('Statistics & Streaks'),
          backgroundColor: const Color(0xFF0E1621),
        ),
        body: BlocBuilder<StatisticsCubit, StatisticsState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  HydrationScoreCard(score: state.hydrationScore),
                  const SizedBox(height: 16),
                  StreakCard(streak: state.streak),
                  const SizedBox(height: 24),
                  WeeklyBarChart(cups: state.weeklyCups),
                  const SizedBox(height: 24),
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
      ),
    );
  }
}
