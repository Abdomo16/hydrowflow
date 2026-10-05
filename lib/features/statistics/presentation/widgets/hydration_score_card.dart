import 'package:flutter/material.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';

class HydrationScoreCard extends StatelessWidget {
  final double score;

  const HydrationScoreCard({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
                'Hydration\nScore',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              Icon(Icons.water_drop, color: colors.primary, size: 18),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${score.toStringAsFixed(0)}%',
            style: TextStyle(
              color: colors.primary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
