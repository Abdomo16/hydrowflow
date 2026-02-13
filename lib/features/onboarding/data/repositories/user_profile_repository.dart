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

  Future<Map<String, dynamic>?> getProfile() async {
    final db = await AppDatabase.database;

    final result = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (result.isEmpty) return null;

    return result.first;
  }

  Future<void> updateProfile({
    required double height,
    required double weight,
    required String activityLevel,
    required double dailyGoal,
  }) async {
    final db = await AppDatabase.database;

    await db.update(
      'user_profile',
      {
        'height': height,
        'weight': weight,
        'activity_level': activityLevel,
        'daily_goal': dailyGoal,
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}
