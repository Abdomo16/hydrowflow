import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/features/onboarding/data/repositories/user_profile_repository.dart';

import 'onboarding_state.dart';
import '../data/models/onboarding_model.dart';

// NEW imports (added only)
import '../../../utils/water_calculator.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(OnboardingState.initial());

  // ========================
  // Existing logic (unchanged)
  // ========================

  void updateHeight(double value) {
    final updatedModel = state.model.copyWith(heightCm: value);
    emit(state.copyWith(model: updatedModel));
  }

  void updateWeight(double value) {
    final updatedModel = state.model.copyWith(weightKg: value);
    emit(state.copyWith(model: updatedModel));
  }

  void updateActivity(ActivityLevel level) {
    final updatedModel = state.model.copyWith(activityLevel: level);
    emit(state.copyWith(model: updatedModel));
  }

  void validate() {
    final valid =
        (state.model.heightCm ?? 0) > 0 && (state.model.weightKg ?? 0) > 0;

    emit(state.copyWith(isValid: valid));
  }

  Future<double?> finishOnboarding() async {
    try {
      final model = state.model;

      if (model.heightCm == null ||
          model.weightKg == null ||
          model.activityLevel == null) {
        debugPrint(' Invalid onboarding data');
        return null;
      }

      final dailyGoal = WaterCalculator.calculate(model);

      debugPrint(' Daily goal calculated: $dailyGoal');

      await UserProfileRepository().saveProfile(model, dailyGoal);

      debugPrint(' Profile saved to DB');

      return dailyGoal;
    } catch (e, s) {
      debugPrint(' finishOnboarding error: $e');
      debugPrintStack(stackTrace: s);
      return null;
    }
  }
}
