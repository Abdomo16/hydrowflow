import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_state.dart';
import '../data/models/onboarding_model.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(OnboardingState.initial());

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
}
