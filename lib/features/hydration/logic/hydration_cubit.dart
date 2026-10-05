import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/hydration_repository.dart';
import 'hydration_state.dart';

class HydrationCubit extends Cubit<HydrationState> {
  final HydrationRepository repository;

  /// Called after drinks change so dependent work (e.g. reminders) can update.
  final Future<void> Function()? onLogsChanged;

  static const int defaultCupSizeMl = 250;

  HydrationCubit({
    required double dailyGoalLiters,
    required this.repository,
    this.onLogsChanged,
  }) : super(HydrationState.initial(dailyGoalLiters)) {
    loadToday();
  }

  Future<void> updateGoal(double newGoal) async {
    if (newGoal == state.dailyGoalLiters) return;

    final newTotalCups = (newGoal * 1000 / defaultCupSizeMl).round();

    emit(
      state.copyWith(
        dailyGoalLiters: newGoal,
        totalCups: newTotalCups,
      ),
    );
  }

  Future<void> loadToday() async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final cups = await repository.getTodayCups();
      final ml = await repository.getTodayMl();
      final logs = await repository.getTodayLogs();

      emit(
        state.copyWith(
          consumedCups: cups,
          consumedMl: ml,
          logs: logs,
          loading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: 'Failed to load hydration data'));
    }
  }

  Future<void> addCup() => addDrink(defaultCupSizeMl);

  Future<void> addDrink(int amountMl) async {
    if (amountMl <= 0) return;

    emit(state.copyWith(loading: true, error: null));

    try {
      await repository.addDrink(amountMl);
      await loadToday();
      await onLogsChanged?.call();
    } catch (e) {
      emit(state.copyWith(loading: false, error: 'Failed to add drink'));
    }
  }

  Future<void> deleteLog(int id) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      await repository.deleteLog(id);
      await loadToday();
      await onLogsChanged?.call();
    } catch (e) {
      emit(state.copyWith(loading: false, error: 'Failed to delete log'));
    }
  }

  Future<void> undoLast() async {
    emit(state.copyWith(loading: true, error: null));

    try {
      await repository.undoLast();
      await loadToday();
      await onLogsChanged?.call();
    } catch (e) {
      emit(state.copyWith(loading: false, error: 'Failed to undo'));
    }
  }
}
