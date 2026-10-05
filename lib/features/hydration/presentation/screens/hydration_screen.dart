import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import 'package:hydrowflow/features/hydration/presentation/widgets/add_cup_button.dart';
import 'package:hydrowflow/features/hydration/presentation/widgets/drink_type_selector.dart';
import 'package:hydrowflow/features/hydration/presentation/widgets/today_log_list.dart';
import 'package:hydrowflow/features/hydration/presentation/widgets/water_glass.dart';

import '../../logic/hydration_cubit.dart';
import '../../logic/hydration_state.dart';

class HydrationScreen extends StatelessWidget {
  const HydrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Hydration Tracker')),

      body: BlocConsumer<HydrationCubit, HydrationState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          if (state.loading && state.logs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 28,
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      const TextSpan(text: 'You need '),
                      TextSpan(
                        text:
                            '${state.dailyGoalLiters.toStringAsFixed(1)} Liters',
                        style: TextStyle(color: colors.primary),
                      ),
                      const TextSpan(text: '\ntoday'),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '= ${state.totalCups} cups (${state.consumedMl} ml logged)',
                  style: TextStyle(color: colors.textSecondary, fontSize: 14),
                ),

                const SizedBox(height: 32),

                WaterGlass(progress: state.progress),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daily Progress',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontFamily: 'Inter'),
                        children: [
                          TextSpan(
                            text: '${state.consumedCups}',
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: ' / ',
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                          TextSpan(
                            text: '${state.totalCups} cups',
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: state.progress,
                    minHeight: 9,
                    backgroundColor: colors.surfaceAlt,
                    valueColor: AlwaysStoppedAnimation(colors.primary),
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  state.motivationMessage,
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                ),

                const SizedBox(height: 24),

                const DrinkTypeSelector(),

                const SizedBox(height: 16),

                const AddCupButton(),

                const SizedBox(height: 32),

                TodayLogList(
                  logs: state.logs,
                  onDelete: context.read<HydrationCubit>().deleteLog,
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
