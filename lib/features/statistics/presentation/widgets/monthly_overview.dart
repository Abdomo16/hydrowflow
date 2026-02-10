import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyOverview extends StatelessWidget {
  final double avg;
  final double completion;
  final String bestDay;

  const MonthlyOverview({
    super.key,
    required this.avg,
    required this.completion,
    required this.bestDay,
  });

  /// Converts date string (yyyy-MM-dd) to "10 October"
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
        const Text(
          'Monthly Overview',
          style: TextStyle(
            color: Colors.white,
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF16202A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
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
