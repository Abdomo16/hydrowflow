import 'package:flutter/material.dart';
import 'package:hydrowflow/features/statistics/presentation/widgets/bar_builder.dart';

class WeeklyBarChart extends StatelessWidget {
  final String title;
  final List<int> cups;
  final List<String> labels;
  final bool spread;

  const WeeklyBarChart({
    super.key,
    required this.title,
    required this.cups,
    required this.labels,
    this.spread = false,
  });

  @override
  Widget build(BuildContext context) {
    final total = cups.fold(0, (a, b) => a + b);
    final max = cups.isEmpty ? 1 : cups.reduce((a, b) => a > b ? a : b);

    // Empty state
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF16202A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            const Icon(
              Icons.water_drop_outlined,
              color: Colors.white24,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'No data yet',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF16202A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              Text(
                '$total Cups',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          spread
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: BarBuilder.buildBars(
                    cups: cups,
                    labels: labels,
                    max: max,
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: cups.length * 70,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: BarBuilder.buildBars(
                        cups: cups,
                        labels: labels,
                        max: max,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
