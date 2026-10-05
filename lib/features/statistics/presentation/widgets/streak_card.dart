import 'package:flutter/material.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';

class StreakCard extends StatelessWidget {
  final int streak;

  const StreakCard({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final subtitle = streak == 0
        ? 'Start your first streak 💧'
        : 'Keep going, don’t stop 🔥';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Current\nStreak',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.local_fire_department,
                color: colors.warning,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '$streak days',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
