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
    final streak = await repo.getStreak(targetCups);
    final weekly = await repo.getWeeklyCups();
    final monthly = await repo.getMonthlyStats(targetCups);

    final totalWeekly = weekly.isEmpty ? 0 : weekly.reduce((a, b) => a + b);

    final maxDays = weekly.length == 1 ? 1 : 7;

    final hydrationScore = totalWeekly == 0
        ? 0.0
        : (totalWeekly / (targetCups * maxDays)) * 100;

    emit(
      state.copyWith(
        streak: streak,
        weeklyCups: weekly,
        hydrationScore: hydrationScore.clamp(0, 100),
        avgMonthly: monthly['avg'],
        completionRate: monthly['completion'],
        bestDay: monthly['bestDay'],
        loading: false,
      ),
    );
  }

  ///  TOGGLE VIEW
  void changeView(StatsView view) {
    emit(state.copyWith(view: view));
  }
}
