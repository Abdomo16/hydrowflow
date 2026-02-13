import 'package:hydrowflow/features/profile/data/models/profile_model.dart';

class ProfileState {
  final ProfileModel? profile;
  final bool isLoading;
  final bool isSaved;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isSaved = false,
  });

  factory ProfileState.initial() {
    return const ProfileState();
  }

  ProfileState copyWith({
    ProfileModel? profile,
    bool? isLoading,
    bool? isSaved,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isSaved: isSaved ?? false,
    );
  }
}
