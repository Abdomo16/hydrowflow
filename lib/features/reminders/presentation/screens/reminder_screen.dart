import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hydrowflow/core/di/service_locator.dart';
import 'package:hydrowflow/features/reminders/data/repositories/reminder_repository.dart';
import 'package:hydrowflow/features/reminders/logic/reminder_coordinator.dart';
import 'package:hydrowflow/features/reminders/logic/reminder_cubit.dart';
import 'package:hydrowflow/features/reminders/logic/reminder_state.dart';

import 'package:hydrowflow/features/reminders/presentation/widgets/active_hours_card.dart';
import 'package:hydrowflow/features/reminders/presentation/widgets/frequency_selector.dart';
import 'package:hydrowflow/features/reminders/presentation/widgets/reminder_status_card.dart';
import 'package:hydrowflow/features/reminders/presentation/widgets/reminder_toggle.dart';
import 'package:hydrowflow/features/reminders/presentation/widgets/sound_selector.dart';
import 'package:hydrowflow/features/reminders/presentation/widgets/test_notification_button.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReminderCubit(
        locator<ReminderRepository>(),
        locator<ReminderCoordinator>(),
      ),
      child: const _ReminderView(),
    );
  }
}

class _ReminderView extends StatefulWidget {
  const _ReminderView();

  @override
  State<_ReminderView> createState() => _ReminderViewState();
}

class _ReminderViewState extends State<_ReminderView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<ReminderCubit>().refreshPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: BlocBuilder<ReminderCubit, ReminderState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final cubit = context.read<ReminderCubit>();

          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(overscroll: false),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReminderToggle(
                    value: state.settings.enabled,
                    onChanged: cubit.toggle,
                  ),

                  const SizedBox(height: 12),

                  const ReminderStatusCard(),

                  const SizedBox(height: 24),

                  FrequencySelector(
                    selected: state.settings.frequencyMinutes,
                    onSelect: cubit.changeFrequency,
                  ),

                  const SizedBox(height: 24),

                  ActiveHoursCard(
                    wake: state.settings.wakeTime,
                    sleep: state.settings.sleepTime,
                  ),

                  const SizedBox(height: 32),

                  const SoundSelector(),

                  const SizedBox(height: 32),

                  const TestNotificationButton(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
