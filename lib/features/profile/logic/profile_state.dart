import 'package:hydrowflow/features/profile/data/models/profile_model.dart';

class ProfileState {
  final ProfileModel? profile;
  final bool isLoading;
  final bool isSaving;
  final bool isSaved;
  final String? error;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isSaving = false,
    this.isSaved = false,
    this.error,
  });

  factory ProfileState.initial() {
    return const ProfileState();
  }

  ProfileState copyWith({
    ProfileModel? profile,
    bool? isLoading,
    bool? isSaving,
    bool? isSaved,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isSaved: isSaved ?? this.isSaved,
      error: error,
    );
  }
}
