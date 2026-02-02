import 'package:flutter/material.dart';

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
    final options = [30, 60, 120];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequency',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
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
              selectedColor: Colors.blue.withOpacity(0.9),
              backgroundColor: const Color(0xFF1E293B),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Colors.blue
                      : Colors.white.withOpacity(0.15),
                  width: 3,
                ),
              ),

              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
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
