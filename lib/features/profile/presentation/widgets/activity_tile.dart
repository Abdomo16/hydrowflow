import 'package:flutter/material.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import '../../../onboarding/data/models/onboarding_model.dart';

class ActivityTileWidget extends StatelessWidget {
  final ActivityLevel level;
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const ActivityTileWidget({
    super.key,
    required this.level,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      height: 73,
      decoration: BoxDecoration(
        color: selected ? colors.primarySoft : colors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: selected ? colors.primary : colors.border,
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: selected
                ? colors.primary.withValues(alpha: 0.12)
                : colors.shadow,
            blurRadius: selected ? 12 : 8,
            offset: Offset(0, selected ? 6 : 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 40,
                  decoration: BoxDecoration(
                    color: selected ? colors.surface : colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 23,
                    color: selected ? colors.primary : colors.textSecondary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        getSubtitle(),
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 20,
                  color: selected ? colors.primary : colors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getSubtitle() {
    switch (level) {
      case ActivityLevel.low:
        return "Little or no exercise";
      case ActivityLevel.medium:
        return "Exercise 2–4 days per week";
      case ActivityLevel.high:
        return "Daily intense activity";
    }
  }
}
