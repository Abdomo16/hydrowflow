import 'package:get_it/get_it.dart';
import 'package:hydrowflow/features/auth/data/repositories/auth_repository.dart';
import 'package:hydrowflow/features/hydration/data/hydration_repository.dart';
import 'package:hydrowflow/features/onboarding/data/repositories/user_profile_repository.dart';
import 'package:hydrowflow/features/reminders/data/repositories/reminder_repository.dart';
import 'package:hydrowflow/features/settings/data/repositories/settings_repository.dart';
import 'package:hydrowflow/features/statistics/data/repositories/statistics_repository.dart';
import 'package:hydrowflow/features/subscription/data/repositories/subscription_repository.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator
    ..registerLazySingleton(AuthRepository.new)
    ..registerLazySingleton(HydrationRepository.new)
    ..registerLazySingleton(UserProfileRepository.new)
    ..registerLazySingleton(ReminderRepository.new)
    ..registerLazySingleton(SettingsRepository.new)
    ..registerLazySingleton(StatisticsRepository.new)
    ..registerLazySingleton(SubscriptionRepository.new);
}
