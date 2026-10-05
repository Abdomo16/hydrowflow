import 'package:flutter/material.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class MonthlyOverview extends StatelessWidget {
  final String title;
  final double avg;
  final double completion;
  final String bestDay;

  const MonthlyOverview({
    super.key,
    this.title = 'Monthly Overview',
    required this.avg,
    required this.completion,
    required this.bestDay,
  });

  /// Converts date string (yyyy-MM-dd) to "10 Oct"
  String _formatBestDay(String date) {
    if (date.isEmpty) return '-';

    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('d MMM').format(parsedDate);
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _MiniCard('Avg. Intake', '${avg.toStringAsFixed(1)} cups'),
            const SizedBox(width: 12),
            _MiniCard('Completion', '${completion.toStringAsFixed(0)}%'),
            const SizedBox(width: 12),
            _MiniCard('Best Day', _formatBestDay(bestDay)),
          ],
        ),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String title;
  final String value;

  const _MiniCard(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
