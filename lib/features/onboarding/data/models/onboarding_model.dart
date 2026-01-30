class OnboardingModel {
  final double? heightCm;
  final double? weightKg;
  final ActivityLevel activityLevel;

  const OnboardingModel({
    this.heightCm,
    this.weightKg,
    required this.activityLevel,
  });

  OnboardingModel copyWith({
    double? heightCm,
    double? weightKg,
    ActivityLevel? activityLevel,
  }) {
    return OnboardingModel(
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }
}

enum ActivityLevel { low, medium, high }
