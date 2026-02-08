import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/statistics_repository.dart';
import 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final StatisticsRepository repo;
  final int targetCups;

  StatisticsCubit(this.repo, this.targetCups)
    : super(StatisticsState.initial()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(loading: true));

    final streak = await repo.getStreak(targetCups);
    final weekly = await repo.getWeeklyCups();
    final monthly = await repo.getMonthlyStats(targetCups);

    // 🔹 MONTHLY PROGRESS = cups per week (4 weeks)
    final monthlyCups = <int>[0, 0, 0, 0];
    for (int i = 0; i < weekly.length; i++) {
      final weekIndex = i ~/ 7;
      if (weekIndex < 4) {
        monthlyCups[weekIndex] += weekly[i];
      }
    }

    final totalWeekly = weekly.isEmpty ? 0 : weekly.reduce((a, b) => a + b);
    final maxDays = weekly.length == 1 ? 1 : 7;

    final hydrationScore = totalWeekly == 0
        ? 0.0
        : (totalWeekly / (targetCups * maxDays)) * 100;

    emit(
      state.copyWith(
        streak: streak,
        weeklyCups: weekly,
        monthlyCups: monthlyCups,
        hydrationScore: hydrationScore.clamp(0, 100),
        avgMonthly: monthly['avg'],
        completionRate: monthly['completion'],
        bestDay: monthly['bestDay'],
        loading: false,
      ),
    );
  }

  void changeView(StatsView view) {
    emit(state.copyWith(view: view));
  }
}
