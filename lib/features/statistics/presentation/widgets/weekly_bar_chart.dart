import 'package:flutter/material.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<int> cups;

  const WeeklyBarChart({super.key, required this.cups});

  @override
  Widget build(BuildContext context) {
    final total = cups.fold(0, (a, b) => a + b);
    final max = cups.isEmpty ? 1 : cups.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF16202A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Progress',
            style: TextStyle(color: Colors.white54, fontSize: 13),
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
              const SizedBox(width: 8),
              const Text(
                '+12% vs last week',
                style: TextStyle(
                  color: Color(0xFF22C55E),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(cups.length, (i) {
              final h = max == 0 ? 0.0 : (cups[i] / max) * 120;
              return Column(
                children: [
                  Container(
                    width: 18,
                    height: h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F8BEF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
