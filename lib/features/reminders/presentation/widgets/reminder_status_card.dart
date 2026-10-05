import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import 'package:hydrowflow/features/reminders/logic/reminder_cubit.dart';
import 'package:hydrowflow/features/reminders/logic/reminder_state.dart';

class ReminderStatusCard extends StatelessWidget {
  const ReminderStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<ReminderCubit, ReminderState>(
      builder: (context, state) {
        if (state.permissionDenied) {
          return _StatusBox(
            icon: Icons.notifications_off_outlined,
            color: colors.danger,
            title: 'Notifications are blocked',
            subtitle: Platform.isIOS
                ? 'Open Settings > HydroFlow > Notifications and turn on Allow Notifications.'
                : 'Open Settings > Apps > HydroFlow > Notifications and allow them.',
            action: TextButton(
              onPressed: () => context.read<ReminderCubit>().toggle(true),
              child: const Text('Try again'),
            ),
          );
        }

        final settings = state.settings;
        final status = state.status;

        if (!settings.enabled) {
          return _StatusBox(
            icon: Icons.notifications_paused_outlined,
            color: colors.textMuted,
            title: 'Reminders are off',
            subtitle:
                'Turn them on to get reminded between ${settings.wakeTime} and ${settings.sleepTime}.',
          );
        }

        final next = status.nextReminderAt;
        final nextText = next == null ? null : _describe(context, next);

        if (status.goalReachedToday) {
          return _StatusBox(
            icon: Icons.check_circle_outline,
            color: colors.success,
            title: 'Goal reached for today',
            subtitle: nextText == null
                ? 'Great job! No more reminders today.'
                : 'Great job! Reminders resume $nextText.',
          );
        }

        return Column(
          children: [
            _StatusBox(
              icon: Icons.schedule,
              color: colors.primary,
              title: nextText == null
                  ? 'No more reminders today'
                  : 'Next reminder $nextText',
              subtitle:
                  'Logging a drink restarts the timer, and reminders stop once you reach your goal.',
            ),
            if (Platform.isAndroid) ...[
              const SizedBox(height: 10),
              const _BatteryTip(),
            ],
          ],
        );
      },
    );
  }

  static String _describe(BuildContext context, DateTime at) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(at.year, at.month, at.day);
    final time = TimeOfDay.fromDateTime(at).format(context);

    final diffDays = DateTime.utc(day.year, day.month, day.day)
        .difference(DateTime.utc(today.year, today.month, today.day))
        .inDays;

    if (diffDays == 0) return 'at $time';
    if (diffDays == 1) return 'tomorrow at $time';
    return 'on ${at.day}/${at.month} at $time';
  }
}

class _StatusBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget? action;

  const _StatusBox({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: colors.textSecondary, fontSize: 12.5),
                ),
                if (action != null)
                  Align(alignment: Alignment.centerLeft, child: action),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BatteryTip extends StatelessWidget {
  const _BatteryTip();

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.textMuted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.battery_alert_outlined, color: muted, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Not getting reminders? On Xiaomi, Oppo, Realme, Huawei or Samsung, '
            'set HydroFlow to "No restrictions" in battery settings.',
            style: TextStyle(color: muted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
