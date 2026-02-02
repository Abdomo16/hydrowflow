import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/features/reminders/data/repositories/reminder_repository.dart';
import 'package:hydrowflow/features/reminders/logic/reminder_cubit.dart';
import 'package:hydrowflow/features/reminders/logic/reminder_state.dart';
import 'package:hydrowflow/features/reminders/presentation/widgets/active_hours_card.dart';
import 'package:hydrowflow/features/reminders/presentation/widgets/frequency_selector.dart';
import 'package:hydrowflow/features/reminders/presentation/widgets/reminder_toggle.dart';
import 'package:hydrowflow/features/reminders/presentation/widgets/sound_selector.dart';
import 'package:hydrowflow/features/reminders/presentation/widgets/test_notification_button.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReminderCubit(ReminderRepository()),
      child: Scaffold(
        backgroundColor: const Color(0xFF0E1621),
        appBar: AppBar(
          title: const Text('Reminders'),
          backgroundColor: const Color(0xFF0E1621),
        ),
        body: BlocBuilder<ReminderCubit, ReminderState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReminderToggle(
                    value: state.settings.enabled,
                    onChanged: (v) => context.read<ReminderCubit>().toggle(v),
                  ),

                  const SizedBox(height: 24),

                  FrequencySelector(
                    selected: state.settings.frequencyMinutes,
                    onSelect: (v) =>
                        context.read<ReminderCubit>().changeFrequency(v),
                  ),

                  const SizedBox(height: 24),

                  ActiveHoursCard(
                    wake: state.settings.wakeTime,
                    sleep: state.settings.sleepTime,
                  ),

                  const SizedBox(height: 32),
                  const SoundSelector(),
                  const SizedBox(height: 32),

                  //  TEST NOTIFICATION BUTTON
                  const TestNotificationButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
