import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/hydration_repository.dart';
import '../data/models/drink_type.dart';
import 'hydration_state.dart';

class HydrationCubit extends Cubit<HydrationState> {
  final HydrationRepository repository;

  /// Called after drinks change so dependent work (e.g. reminders) can update.
  final Future<void> Function()? onLogsChanged;

  /// Called once when a new drink takes today's total past the goal.
  final void Function()? onGoalReached;

  static const int defaultCupSizeMl = 250;

  HydrationCubit({
    required double dailyGoalLiters,
    required this.repository,
    this.onLogsChanged,
    this.onGoalReached,
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

  void selectDrink(DrinkType type) {
    if (type != state.selectedDrink) emit(state.copyWith(selectedDrink: type));
  }

  Future<void> addDrink(int amountMl, {DrinkType? type}) async {
    if (amountMl <= 0) return;

    final wasReached = state.goalReached;
    emit(state.copyWith(loading: true, error: null));

    try {
      await repository.addDrink(amountMl, type: type ?? state.selectedDrink);
      await loadToday();
      if (!wasReached && state.goalReached) onGoalReached?.call();
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
