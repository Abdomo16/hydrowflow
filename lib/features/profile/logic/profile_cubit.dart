import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/features/onboarding/data/repositories/user_profile_repository.dart';

import '../data/models/profile_model.dart';
import 'profile_state.dart';

import '../../onboarding/data/models/onboarding_model.dart';
import '../../../utils/water_calculator.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UserProfileRepository repository;

  ProfileCubit(this.repository) : super(ProfileState.initial());

  Future<void> loadProfile() async {
    emit(state.copyWith(isLoading: true));

    final data = await repository.getProfile();

    if (data != null) {
      final profile = ProfileModel.fromMap(data);
      emit(state.copyWith(profile: profile, isLoading: false));
    }
  }

  void updateHeight(double value) {
    final current = state.profile;
    if (current == null) return;

    emit(
      state.copyWith(
        profile: ProfileModel(
          height: value,
          weight: current.weight,
          activityLevel: current.activityLevel,
          dailyGoal: current.dailyGoal,
        ),
      ),
    );
  }

  void updateWeight(double value) {
    final current = state.profile;
    if (current == null) return;

    emit(
      state.copyWith(
        profile: ProfileModel(
          height: current.height,
          weight: value,
          activityLevel: current.activityLevel,
          dailyGoal: current.dailyGoal,
        ),
      ),
    );
  }

  void updateActivity(ActivityLevel level) {
    final current = state.profile;
    if (current == null) return;

    emit(
      state.copyWith(
        profile: ProfileModel(
          height: current.height,
          weight: current.weight,
          activityLevel: level,
          dailyGoal: current.dailyGoal,
        ),
      ),
    );
  }

  Future<void> saveProfile() async {
    final current = state.profile;
    if (current == null) return;

    emit(state.copyWith(isLoading: true));

    final onboardingModel = OnboardingModel(
      heightCm: current.height,
      weightKg: current.weight,
      activityLevel: current.activityLevel,
    );

    final newGoal = WaterCalculator.calculate(onboardingModel);

    await repository.updateProfile(
      height: current.height,
      weight: current.weight,
      activityLevel: current.activityLevel.name,
      dailyGoal: newGoal,
    );

    emit(
      state.copyWith(
        profile: ProfileModel(
          height: current.height,
          weight: current.weight,
          activityLevel: current.activityLevel,
          dailyGoal: newGoal,
        ),
        isLoading: false,
        isSaved: true,
      ),
    );
  }
}
