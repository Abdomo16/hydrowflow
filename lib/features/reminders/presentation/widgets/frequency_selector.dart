import 'package:flutter/material.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import 'package:hydrowflow/features/reminders/logic/reminder_tier.dart';

class FrequencySelector extends StatelessWidget {
  final int selected;
  final bool premium;
  final ValueChanged<int> onSelect;
  final VoidCallback onLockedTap;

  const FrequencySelector({
    super.key,
    required this.selected,
    required this.premium,
    required this.onSelect,
    required this.onLockedTap,
  });

  static String _label(int minutes) {
    if (minutes < 60) return 'Every $minutes min';
    if (minutes == 60) return 'Every hour';
    if (minutes % 60 == 0) return 'Every ${minutes ~/ 60} hours';
    return 'Every ${minutes / 60} hours';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Remind me every',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          premium
              ? 'Smart: the timer restarts after each drink and pauses '
                    'once you reach your goal.'
              : 'Reminders repeat on a fixed schedule. Premium makes them '
                    'smart: they wait after each drink and stop at your goal.',
          style: TextStyle(color: colors.textSecondary, fontSize: 12.5),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: ReminderTier.allIntervals.map((minutes) {
            final locked = !premium && !ReminderTier.isIntervalFree(minutes);
            final isSelected = selected == minutes;

            return ChoiceChip(
              avatar: locked
                  ? Icon(Icons.lock, size: 14, color: colors.textMuted)
                  : null,
              label: Text(_label(minutes)),
              selected: isSelected,
              showCheckmark: false,
              selectedColor: colors.primary,
              backgroundColor: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? colors.primary : colors.border,
                  width: 1.5,
                ),
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? colors.onPrimary
                    : locked
                    ? colors.textMuted
                    : colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) => locked ? onLockedTap() : onSelect(minutes),
            );
          }).toList(),
        ),
      ],
    );
  }
}
