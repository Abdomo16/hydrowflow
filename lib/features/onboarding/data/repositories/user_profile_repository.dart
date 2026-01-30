import 'package:hydrowflow/database/app_database.dart';

import '../models/onboarding_model.dart';
import 'package:sqflite/sqflite.dart';

class UserProfileRepository {
  Future<void> saveProfile(OnboardingModel model, double dailyGoal) async {
    final db = await AppDatabase.database;

    await db.insert('user_profile', {
      'id': 1,
      'height': model.heightCm,
      'weight': model.weightKg,
      'activity_level': model.activityLevel.name,
      'daily_goal': dailyGoal,
      'onboarding_done': 1,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
