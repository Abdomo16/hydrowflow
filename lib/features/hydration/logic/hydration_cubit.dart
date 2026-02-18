import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/hydration_repository.dart';
import 'hydration_state.dart';
import 'package:hydrowflow/core/notifications/notification_service.dart';

class HydrationCubit extends Cubit<HydrationState> {
  final HydrationRepository repository;

  static const int cupSizeMl = 250;

  HydrationCubit({required double dailyGoalLiters, required this.repository})
    : super(
        HydrationState(
          dailyGoalLiters: dailyGoalLiters,
          totalCups: (dailyGoalLiters * 1000 / cupSizeMl).round(),
          consumedCups: 0,
        ),
      ) {
    loadToday();
  }

  /// Update daily goal dynamically
  Future<void> updateGoal(double newGoal) async {
    if (newGoal == state.dailyGoalLiters) return;

    final newTotalCups = (newGoal * 1000 / cupSizeMl).round();

    final updatedState = state.copyWith(
      dailyGoalLiters: newGoal,
      totalCups: newTotalCups,
    );

    emit(updatedState);

    // Stop reminders if goal already reached after update
    if (updatedState.consumedCups >= updatedState.totalCups) {
      await NotificationService.cancelAll();
    }
  }

  /// Load today's hydration progress
  Future<void> loadToday() async {
    final cups = await repository.getTodayCups();

    final updatedState = state.copyWith(consumedCups: cups);

    emit(updatedState);

    // Stop reminders if goal already reached
    if (updatedState.consumedCups >= updatedState.totalCups) {
      await NotificationService.cancelAll();
    }
  }

  /// Add one cup
  Future<void> addCup() async {
    if (state.consumedCups >= state.totalCups) return;

    await repository.addCup();

    final newConsumed = state.consumedCups + 1;

    final updatedState = state.copyWith(consumedCups: newConsumed);

    emit(updatedState);

    // Stop reminders if goal reached
    if (updatedState.consumedCups >= updatedState.totalCups) {
      await NotificationService.cancelAll();
    }
  }
}
