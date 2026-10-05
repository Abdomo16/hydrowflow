import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/di/service_locator.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import 'package:hydrowflow/features/onboarding/data/repositories/user_profile_repository.dart';

import '../../logic/profile_cubit.dart';
import '../../logic/profile_state.dart';
import '../../../onboarding/data/models/onboarding_model.dart';

import '../widgets/profile_input_card.dart';
import '../widgets/activity_tile.dart';
import '../widgets/save_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController heightController;
  late TextEditingController weightController;
  String? heightError;
  String? weightError;

  @override
  void initState() {
    super.initState();
    heightController = TextEditingController();
    weightController = TextEditingController();
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      heightError == null &&
      weightError == null &&
      heightController.text.isNotEmpty &&
      weightController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocProvider(
      create: (_) => ProfileCubit(locator<UserProfileRepository>())..loadProfile(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: BlocConsumer<ProfileCubit, ProfileState>(
              listener: (context, state) {
                if (state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error!)),
                  );
                }
                if (state.profile != null &&
                    heightController.text.isEmpty &&
                    weightController.text.isEmpty) {
                  heightController.text = state.profile!.height % 1 == 0
                      ? state.profile!.height.toInt().toString()
                      : state.profile!.height.toString();

                  weightController.text = state.profile!.weight % 1 == 0
                      ? state.profile!.weight.toInt().toString()
                      : state.profile!.weight.toString();
                }
              },
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.profile == null) {
                  return Center(
                    child: Text(
                      'Profile not found',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  );
                }

                final cubit = context.read<ProfileCubit>();
                final profile = state.profile!;

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom -
                          kToolbarHeight -
                          24,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current goal: ${profile.dailyGoal.toStringAsFixed(1)} L / day',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ProfileInputCard(
                            label: "HEIGHT",
                            controller: heightController,
                            unit: "cm",
                            errorText: heightError,
                            onChanged: (v) {
                              final parsed = double.tryParse(v);
                              if (parsed == null || parsed < 100 || parsed > 250) {
                                setState(() => heightError = 'Enter 100-250 cm');
                                return;
                              }
                              setState(() => heightError = null);
                              cubit.updateHeight(parsed);
                            },
                          ),
                          const SizedBox(height: 16),
                          ProfileInputCard(
                            label: "WEIGHT",
                            controller: weightController,
                            unit: "kg",
                            errorText: weightError,
                            onChanged: (v) {
                              final parsed = double.tryParse(v);
                              if (parsed == null || parsed < 30 || parsed > 250) {
                                setState(() => weightError = 'Enter 30-250 kg');
                                return;
                              }
                              setState(() => weightError = null);
                              cubit.updateWeight(parsed);
                            },
                          ),
                          const SizedBox(height: 30),
                          Text(
                            "Activity Level",
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ActivityTileWidget(
                            level: ActivityLevel.low,
                            title: "Low",
                            icon: Icons.self_improvement,
                            selected:
                                profile.activityLevel == ActivityLevel.low,
                            onTap: () =>
                                cubit.updateActivity(ActivityLevel.low),
                          ),
                          const SizedBox(height: 22),
                          ActivityTileWidget(
                            level: ActivityLevel.medium,
                            title: "Medium",
                            icon: Icons.directions_walk,
                            selected:
                                profile.activityLevel == ActivityLevel.medium,
                            onTap: () =>
                                cubit.updateActivity(ActivityLevel.medium),
                          ),
                          const SizedBox(height: 19),
                          ActivityTileWidget(
                            level: ActivityLevel.high,
                            title: "High",
                            icon: Icons.directions_run,
                            selected:
                                profile.activityLevel == ActivityLevel.high,
                            onTap: () =>
                                cubit.updateActivity(ActivityLevel.high),
                          ),
                          const SizedBox(height: 35),
                          SaveButton(
                            saving: state.isSaving,
                            onPressed: _isFormValid && !state.isSaving
                                ? () async {
                                    FocusScope.of(context).unfocus();
                                    final newGoal = await cubit.saveProfile();
                                    if (newGoal == null || !context.mounted) {
                                      return;
                                    }
                                    Navigator.of(context).pop(newGoal);
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
