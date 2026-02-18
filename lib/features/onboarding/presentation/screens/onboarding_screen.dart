import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/features/onboarding/presentation/widgets/_ActivityTile.dart';
import 'package:hydrowflow/features/onboarding/presentation/widgets/_MetricCard.dart';
import '../../logic/onboarding_cubit.dart';
import '../../logic/onboarding_state.dart';
import '../../data/models/onboarding_model.dart';
import 'package:hydrowflow/core/navigation/main_navigation.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0E1621),
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
                      //  Back + Title
                      SizedBox(
                        height: 32,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.chevron_left,
                                  size: 33,
                                  color: Color(0xFF2864A9),
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 2),
                                child: Text(
                                  'Profile Setup',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      //  Step Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'ONBOARDING',
                            style: TextStyle(
                              color: Color(0xFF95A2B9),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Step 1 of 2',
                            style: TextStyle(color: Colors.blue, fontSize: 13),
                          ),
                        ],
                      ),

                      const SizedBox(height: 9),

                      //  Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: const LinearProgressIndicator(
                          value: 0.5,
                          minHeight: 6,
                          backgroundColor: Color(0xFF1F2937),
                          valueColor: AlwaysStoppedAnimation(Color(0xFF2864A9)),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Personal Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'Help us tailor your hydration plan based on your physical stats.',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 🔹 Height & Weight
                      Row(
                        children: const [
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

                      const Text(
                        'DAILY ACTIVITY LEVEL',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
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

                                  if (dailyGoal == null || !context.mounted)
                                    return;

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
                            backgroundColor: Colors.blue,
                            disabledBackgroundColor: Colors.blue.withOpacity(
                              0.3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Calculate My Goal',
                            style: TextStyle(
                              color: Colors.white,
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
