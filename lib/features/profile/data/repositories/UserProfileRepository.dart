import '../../../../database/app_database.dart';
import '../models/profile_model.dart';
import 'package:sqflite/sqflite.dart';

class UserProfileRepository {
  Future<ProfileModel?> getProfile() async {
    final db = await AppDatabase.database;

    final result = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (result.isEmpty) return null;

    return ProfileModel.fromMap(result.first);
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
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
