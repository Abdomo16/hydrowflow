import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/core/notifications/notification_service.dart';
import 'package:hydrowflow/features/reminders/logic/reminder_cubit.dart';

class TestNotificationButton extends StatelessWidget {
  const TestNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          NotificationService.schedule(
            id: 999,
            dateTime: DateTime.now().add(const Duration(seconds: 5)),
            title: 'TEST ',
            body: 'This is your selected sound',
            sound: context.read<ReminderCubit>().state.settings.sound,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Test notification will appear in 5 seconds 🔔'),
            ),
          );
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F8BEF),
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
