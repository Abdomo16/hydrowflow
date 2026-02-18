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
            SnackBar(
              behavior: SnackBarBehavior.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              duration: const Duration(seconds: 3),

              content: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2A38),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                      color: Colors.black.withOpacity(0.25),
                    ),
                  ],
                ),

                child: Row(
                  children: const [
                    Icon(
                      Icons.notifications_active,
                      color: Color(0xFF2F8BEF),
                      size: 22,
                    ),
                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        "Test notification will appear in 5 seconds ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
