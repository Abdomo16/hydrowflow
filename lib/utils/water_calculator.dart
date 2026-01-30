import '../features/onboarding/data/models/onboarding_model.dart';

class WaterCalculator {
  static double calculate(OnboardingModel model) {
    final weight = model.weightKg!;
    double baseMl = weight * 35;

    switch (model.activityLevel) {
      case ActivityLevel.low:
        baseMl *= 1.0;
        break;
      case ActivityLevel.medium:
        baseMl *= 1.2;
        break;
      case ActivityLevel.high:
        baseMl *= 1.4;
        break;
    }

    return baseMl / 1000;
  }
}
