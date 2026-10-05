import 'package:flutter/material.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';

class FrequencySelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const FrequencySelector({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const options = [30, 60, 120];

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
          'The timer restarts each time you log a drink.',
          style: TextStyle(color: colors.textSecondary, fontSize: 12.5),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          children: options.map((minutes) {
            final isSelected = selected == minutes;

            return ChoiceChip(
              label: Text(
                minutes == 60
                    ? 'Every hour'
                    : minutes == 30
                    ? 'Every 30 min'
                    : 'Every 2 hours',
              ),
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
                color: isSelected ? colors.onPrimary : colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) => onSelect(minutes),
            );
          }).toList(),
        ),
      ],
    );
  }
}
