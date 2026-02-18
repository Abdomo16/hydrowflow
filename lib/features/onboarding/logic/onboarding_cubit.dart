import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/features/onboarding/data/repositories/user_profile_repository.dart';

import 'onboarding_state.dart';
import '../data/models/onboarding_model.dart';
import '../../../utils/water_calculator.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(OnboardingState.initial());

  final UserProfileRepository _repository = UserProfileRepository();

  // Update Height
  void updateHeight(double value) {
    // Basic range validation (realistic human height)
    if (value < 100 || value > 250) return;

    final updatedModel = state.model.copyWith(heightCm: value);
    emit(state.copyWith(model: updatedModel));

    validate();
  }

  // Update Weight
  void updateWeight(double value) {
    // Basic range validation (realistic human weight)
    if (value < 30 || value > 250) return;

    final updatedModel = state.model.copyWith(weightKg: value);
    emit(state.copyWith(model: updatedModel));

    validate();
  }

  // Update Activity
  void updateActivity(ActivityLevel level) {
    final updatedModel = state.model.copyWith(activityLevel: level);
    emit(state.copyWith(model: updatedModel));
  }

  // Validate Form
  void validate() {
    final heightValid =
        state.model.heightCm != null &&
        state.model.heightCm! >= 100 &&
        state.model.heightCm! <= 250;

    final weightValid =
        state.model.weightKg != null &&
        state.model.weightKg! >= 30 &&
        state.model.weightKg! <= 250;

    emit(state.copyWith(isValid: heightValid && weightValid));
  }

  // Finish Onboarding
  Future<double?> finishOnboarding() async {
    try {
      if (!state.isValid) {
        debugPrint(' Onboarding form is invalid');
        return null;
      }

      final model = state.model;

      final dailyGoal = WaterCalculator.calculate(model);

      debugPrint(' Daily goal calculated: $dailyGoal');

      await _repository.saveProfile(model, dailyGoal);

      debugPrint(' Profile saved to DB');

      return dailyGoal;
    } catch (e, s) {
      debugPrint(' finishOnboarding error: $e');
      debugPrintStack(stackTrace: s);
      return null;
    }
  }
}
