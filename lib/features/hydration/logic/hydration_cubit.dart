import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/hydration_repository.dart';
import 'hydration_state.dart';
import 'package:hydrowflow/core/notifications/notification_service.dart';

class HydrationCubit extends Cubit<HydrationState> {
  final HydrationRepository repository;

  HydrationCubit({required double dailyGoalLiters, required this.repository})
    : super(
        HydrationState(
          dailyGoalLiters: dailyGoalLiters,
          totalCups: (dailyGoalLiters * 1000 / 250).round(),
          consumedCups: 0,
        ),
      ) {
    loadToday();
  }

  //   update goal dynamically
  void updateGoal(double newGoal) {
    if (newGoal == state.dailyGoalLiters) return;

    final newTotalCups = (newGoal * 1000 / 250).round();

    emit(state.copyWith(dailyGoalLiters: newGoal, totalCups: newTotalCups));
  }

  Future<void> loadToday() async {
    final cups = await repository.getTodayCups();

    emit(state.copyWith(consumedCups: cups));

    // Stop reminders if goal already reached
    if (cups >= state.totalCups) {
      await NotificationService.cancelAll();
    }
  }

  Future<void> addCup() async {
    if (state.consumedCups >= state.totalCups) return;

    await repository.addCup();

    final newConsumed = state.consumedCups + 1;

    emit(state.copyWith(consumedCups: newConsumed));

    // Stop reminders if goal reached
    if (newConsumed >= state.totalCups) {
      await NotificationService.cancelAll();
    }
  }
}
