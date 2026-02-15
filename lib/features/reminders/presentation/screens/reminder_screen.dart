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
          title: const Text("Reminders", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF0E1621),

          elevation: 0,
          scrolledUnderElevation: 0,
        ),

        body: BlocBuilder<ReminderCubit, ReminderState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                overscroll: false, // removes fade/stretch effect
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //  Toggle Reminder ON/OFF
                    ReminderToggle(
                      value: state.settings.enabled,
                      onChanged: (v) => context.read<ReminderCubit>().toggle(v),
                    ),

                    const SizedBox(height: 24),

                    //  Frequency Selector
                    FrequencySelector(
                      selected: state.settings.frequencyMinutes,
                      onSelect: (v) =>
                          context.read<ReminderCubit>().changeFrequency(v),
                    ),

                    const SizedBox(height: 24),

                    //  Active Hours Card
                    ActiveHoursCard(
                      wake: state.settings.wakeTime,
                      sleep: state.settings.sleepTime,
                    ),

                    const SizedBox(height: 32),

                    //  Sound Selector
                    const SoundSelector(),

                    const SizedBox(height: 32),

                    //  Test Notification Button
                    const TestNotificationButton(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
