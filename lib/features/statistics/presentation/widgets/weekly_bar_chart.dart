import 'package:flutter/material.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import 'package:hydrowflow/features/statistics/presentation/widgets/bar_builder.dart';

class WeeklyBarChart extends StatelessWidget {
  final String title;
  final List<int> cups;
  final List<String> labels;
  final int? highlightIndex;

  const WeeklyBarChart({
    super.key,
    required this.title,
    required this.cups,
    required this.labels,
    this.highlightIndex,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = cups.fold(0, (a, b) => a + b);
    final max = cups.isEmpty ? 1 : cups.reduce((a, b) => a > b ? a : b);

    final decoration = BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: colors.border),
    );

    // Empty state
    if (total == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: decoration,
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Icon(Icons.water_drop_outlined, color: colors.textMuted, size: 48),
            const SizedBox(height: 12),
            Text(
              'No data yet',
              style: TextStyle(color: colors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            '$total Cups',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: BarBuilder.maxBarHeight + 44,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: BarBuilder.buildBars(
                context: context,
                cups: cups,
                labels: labels,
                max: max,
                highlightIndex: highlightIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
