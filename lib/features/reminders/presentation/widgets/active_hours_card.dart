import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrowflow/features/reminders/logic/reminder_cubit.dart';

class ActiveHoursCard extends StatelessWidget {
  final String wake;
  final String sleep;

  const ActiveHoursCard({super.key, required this.wake, required this.sleep});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReminderCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Hours',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _TimeTile(
              icon: Icons.wb_sunny_outlined,
              label: 'Wake up time',
              time: wake,
              onPick: (value) => cubit.changeWakeTime(value),
            ),
            const SizedBox(width: 12),
            _TimeTile(
              icon: Icons.nightlight_round,
              label: 'Sleep time',
              time: sleep,
              onPick: (value) => cubit.changeSleepTime(value),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final ValueChanged<String> onPick;

  const _TimeTile({
    required this.icon,
    required this.label,
    required this.time,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final initial = _parseTime(time);
          final picked = await showTimePicker(
            context: context,
            initialTime: initial,
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  timePickerTheme: const TimePickerThemeData(
                    backgroundColor: Color(0xFF0E1621),

                    hourMinuteColor: Color(0xFF223A55),
                    hourMinuteTextColor: Colors.white,

                    dialHandColor: Color(0xFF2F8BEF),
                    dialBackgroundColor: Color(0xFF16202A),

                    entryModeIconColor: Colors.blue,

                    dayPeriodColor: Color(0xFF223A55),
                    dayPeriodTextColor: Colors.white,
                    dayPeriodBorderSide: BorderSide(color: Colors.blue),

                    helpTextStyle: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                  ),
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF2F8BEF),
                    onPrimary: Colors.white,
                    surface: Color(0xFF0E1621),
                    onSurface: Colors.white,
                  ),
                ),
                child: child!,
              );
            },
          );

          if (picked != null) {
            final formatted =
                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
            onPick(formatted);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF16202A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
