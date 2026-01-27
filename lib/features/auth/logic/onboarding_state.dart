import '../data/models/onboarding_model.dart';

class OnboardingState {
  final OnboardingModel model;
  final bool isValid;

  const OnboardingState({required this.model, required this.isValid});

  factory OnboardingState.initial() {
    return OnboardingState(
      model: const OnboardingModel(
        heightCm: 170,
        weightKg: 70,
        activityLevel: ActivityLevel.medium,
      ),
      isValid: true,
    );
  }

  OnboardingState copyWith({OnboardingModel? model, bool? isValid}) {
    return OnboardingState(
      model: model ?? this.model,
      isValid: isValid ?? this.isValid,
    );
  }
}
