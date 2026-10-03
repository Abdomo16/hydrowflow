import 'package:flutter_test/flutter_test.dart';
import 'package:hydrowflow/features/onboarding/data/models/onboarding_model.dart';
import 'package:hydrowflow/utils/water_calculator.dart';

void main() {
  group('WaterCalculator', () {
    test('calculates goal for medium activity male-ish defaults', () {
      final model = OnboardingModel(
        heightCm: 175,
        weightKg: 70,
        activityLevel: ActivityLevel.medium,
      );

      final goal = WaterCalculator.calculate(model);

      expect(goal, greaterThan(2.0));
      expect(goal, lessThan(4.0));
    });

    test('high activity increases goal vs low activity', () {
      final low = OnboardingModel(
        heightCm: 175,
        weightKg: 70,
        activityLevel: ActivityLevel.low,
      );
      final high = OnboardingModel(
        heightCm: 175,
        weightKg: 70,
        activityLevel: ActivityLevel.high,
      );

      expect(WaterCalculator.calculate(high), greaterThan(WaterCalculator.calculate(low)));
    });
  });
}
