import '../../../onboarding/data/models/onboarding_model.dart';

class ProfileModel {
  final double height;
  final double weight;
  final ActivityLevel activityLevel;
  final double dailyGoal;

  const ProfileModel({
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.dailyGoal,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      height: map['height'],
      weight: map['weight'],
      activityLevel: ActivityLevel.values.firstWhere(
        (e) => e.name == map['activity_level'],
      ),
      dailyGoal: map['daily_goal'],
    );
  }
}
