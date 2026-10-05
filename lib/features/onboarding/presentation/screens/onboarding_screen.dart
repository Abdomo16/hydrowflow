import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import 'package:hydrowflow/features/onboarding/presentation/widgets/activity_tile.dart';
import 'package:hydrowflow/features/onboarding/presentation/widgets/metric_card.dart';
import '../../logic/onboarding_cubit.dart';
import '../../logic/onboarding_state.dart';
import '../../data/models/onboarding_model.dart';
import 'package:hydrowflow/core/navigation/main_navigation.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, state) {
              final cubit = context.read<OnboardingCubit>();
              final model = state.model;

              return Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 32,
                        child: Center(
                          child: Text(
                            'Profile Setup',
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      //  Step Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ONBOARDING',
                            style: TextStyle(
                              color: colors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Step 1 of 2',
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 9),

                      //  Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: 0.5,
                          minHeight: 6,
                          backgroundColor: colors.surfaceAlt,
                          valueColor: AlwaysStoppedAnimation(colors.primary),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Personal Details',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Help us tailor your hydration plan based on your physical stats.',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Height & Weight
                      const Row(
                        children: [
                          MetricCard(
                            label: 'HEIGHT (CM)',
                            type: MetricType.height,
                          ),
                          SizedBox(width: 12),
                          MetricCard(
                            label: 'WEIGHT (KG)',
                            type: MetricType.weight,
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      Text(
                        'DAILY ACTIVITY LEVEL',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 12),

                      ActivityTile(
                        icon: Icons.chair,
                        title: 'Low',
                        subtitle: 'Sedentary / Office Work',
                        selected: model.activityLevel == ActivityLevel.low,
                        onTap: () => cubit.updateActivity(ActivityLevel.low),
                      ),

                      ActivityTile(
                        icon: Icons.directions_walk,
                        title: 'Medium',
                        subtitle: 'Active / Daily Exercise',
                        selected: model.activityLevel == ActivityLevel.medium,
                        onTap: () => cubit.updateActivity(ActivityLevel.medium),
                      ),

                      ActivityTile(
                        icon: Icons.fitness_center,
                        title: 'High',
                        subtitle: 'Intense / Athlete',
                        selected: model.activityLevel == ActivityLevel.high,
                        onTap: () => cubit.updateActivity(ActivityLevel.high),
                      ),

                      const SizedBox(height: 24),

                      //  Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: state.isValid
                              ? () async {
                                  final dailyGoal = await cubit
                                      .finishOnboarding();

                                  if (dailyGoal == null || !context.mounted) {
                                    return;
                                  }

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          MainNavigation(dailyGoal: dailyGoal),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            disabledBackgroundColor: colors.primary.withValues(
                              alpha: 0.3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Calculate My Goal',
                            style: TextStyle(
                              color: colors.onPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
