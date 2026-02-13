import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/statistics_repository.dart';
import 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final StatisticsRepository repo;

  int targetCups;

  StatisticsCubit(this.repo, this.targetCups)
    : super(StatisticsState.initial()) {
    load();
  }

  void updateTarget(int newTarget) {
    if (newTarget == targetCups) return;

    targetCups = newTarget;
    load();
  }

  List<int> _normalizeWeek(List<int> cups) {
    final result = List<int>.filled(7, 0);
    for (int i = 0; i < cups.length && i < 7; i++) {
      result[i] = cups[i];
    }
    return result;
  }

  Future<void> load() async {
    emit(state.copyWith(loading: true));

    try {
      final streak = await repo.getStreak(targetCups);
      final rawWeekly = await repo.getWeeklyCups();
      final weekly = _normalizeWeek(rawWeekly);
      final monthly = await repo.getMonthlyStats(targetCups);

      final monthlyCups = List<int>.filled(4, 0);
      monthlyCups[0] = weekly.fold(0, (a, b) => a + b);

      final totalWeekly = weekly.fold(0, (a, b) => a + b);
      final daysWithData = rawWeekly.length;

      final hydrationScore = totalWeekly == 0 || daysWithData == 0
          ? 0.0
          : (totalWeekly / (targetCups * daysWithData)) * 100;

      emit(
        state.copyWith(
          streak: streak,
          weeklyCups: weekly,
          monthlyCups: monthlyCups,
          hydrationScore: hydrationScore.clamp(0, 100),
          avgMonthly: monthly['avg'] as double,
          completionRate: monthly['completion'] as double,
          bestDay: monthly['bestDay'] as String,
          loading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false));
    }
  }

  Future<void> refresh() async {
    await load();
  }

  void changeView(StatsView view) {
    emit(state.copyWith(view: view));
  }
}
