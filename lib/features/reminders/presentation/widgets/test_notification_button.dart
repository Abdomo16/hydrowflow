import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import 'package:hydrowflow/features/reminders/logic/reminder_cubit.dart';

class TestNotificationButton extends StatelessWidget {
  const TestNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          final sent = await context.read<ReminderCubit>().sendTest();

          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 3),
                content: Row(
                  children: [
                    Icon(
                      sent
                          ? Icons.notifications_active
                          : Icons.notifications_off_outlined,
                      color: sent ? colors.primaryLight : colors.danger,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        sent
                            ? 'Test notification sent'
                            : 'Could not send. Please allow notifications.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Send Test Notification',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
