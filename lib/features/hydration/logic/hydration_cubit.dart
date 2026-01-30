import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/hydration_repository.dart';
import 'hydration_state.dart';

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

  Future<void> loadToday() async {
    final cups = await repository.getTodayCups();
    emit(state.copyWith(consumedCups: cups));
  }

  Future<void> addCup() async {
    if (state.consumedCups >= state.totalCups) return;

    await repository.addCup();

    emit(state.copyWith(consumedCups: state.consumedCups + 1));
  }
}
