import 'package:flutter/material.dart';

class WeeklyBarChart extends StatelessWidget {
  final String title;
  final List<int> cups;
  final List<String> labels;

  const WeeklyBarChart({
    super.key,
    required this.title,
    required this.cups,
    required this.labels,
  });

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(cups.length, (i) {
              final h = max == 0 ? 0.0 : (cups[i] / max) * 120;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 30,
                    height: h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF5DB4FF), // light top
                          Color(0xFF2F8BEF), // darker bottom
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    labels[i],
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
