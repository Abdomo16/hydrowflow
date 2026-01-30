import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/features/hydration/presentation/widgets/add_cup_button.dart';
import 'package:hydrowflow/features/hydration/presentation/widgets/water_glass.dart';
import '../../logic/hydration_cubit.dart';
import '../../logic/hydration_state.dart';
import '../../data/hydration_repository.dart';

class HydrationScreen extends StatelessWidget {
  final double dailyGoal;

  const HydrationScreen({super.key, required this.dailyGoal});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HydrationCubit(
        dailyGoalLiters: dailyGoal,
        repository: HydrationRepository(),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0E1621),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0E1621),
          elevation: 0,
          centerTitle: true,

          // Left icon
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: IconButton(
              icon: const Icon(
                Icons.account_circle_outlined,
                color: Colors.white,
                size: 25,
              ),
              onPressed: () {},
            ),
          ),

          // Title
          title: const Text(
            'Hydration Tracker',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          //  Right icon
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.white,
                  size: 19,
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),

        body: BlocBuilder<HydrationCubit, HydrationState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // TITLE
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        const TextSpan(text: 'You need '),
                        TextSpan(
                          text:
                              '${state.dailyGoalLiters.toStringAsFixed(1)} Liters',
                          style: const TextStyle(color: Colors.blue),
                        ),
                        const TextSpan(text: '\ntoday'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '= ${state.totalCups} cups',
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),

                  const SizedBox(height: 32),

                  // WATER GLASS (EXTRACTED)
                  WaterGlass(progress: state.progress),

                  const SizedBox(height: 32),

                  // DAILY PROGRESS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daily Progress',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${state.consumedCups}',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const TextSpan(
                              text: ' / ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            TextSpan(
                              text: '${state.totalCups} cups',
                              style: const TextStyle(
                                color: Colors.white,
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
                      backgroundColor: const Color(0xFF1F2937),
                      valueColor: const AlwaysStoppedAnimation(Colors.blue),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Almost halfway there! Keep it up.',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),

                  const SizedBox(height: 40),

                  // ADD CUP BUTTON
                  const AddCupButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
