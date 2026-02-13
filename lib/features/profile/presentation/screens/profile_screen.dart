import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/app/logic/app_cubit.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(UserProfileRepository())..loadProfile(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0E1621),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: BlocConsumer<ProfileCubit, ProfileState>(
              listener: (context, state) {
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
                if (state.isLoading || state.profile == null) {
                  return const Center(child: CircularProgressIndicator());
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
                          48,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                          ProfileInputCard(
                            label: "HEIGHT",
                            controller: heightController,
                            unit: "cm",
                            onChanged: (v) {
                              final parsed = double.tryParse(v);
                              if (parsed != null) {
                                cubit.updateHeight(parsed);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          ProfileInputCard(
                            label: "WEIGHT",
                            controller: weightController,
                            unit: "kg",
                            onChanged: (v) {
                              final parsed = double.tryParse(v);
                              if (parsed != null) {
                                cubit.updateWeight(parsed);
                              }
                            },
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Activity Level",
                            style: TextStyle(
                              color: Colors.white,
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
                            onPressed: () async {
                              await cubit.saveProfile();
                              final newGoal = cubit.state.profile!.dailyGoal;

                              context.read<AppCubit>().updateGoal(newGoal);
                            },
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
