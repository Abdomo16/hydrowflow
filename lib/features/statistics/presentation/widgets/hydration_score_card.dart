import 'package:flutter/material.dart';

class HydrationScoreCard extends StatelessWidget {
  final double score;

  const HydrationScoreCard({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF16202A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'Hydration\nScore',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              Spacer(),
              Icon(Icons.water_drop, color: Color(0xFF2F8BEF), size: 18),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${score.toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Color(0xFF2F8BEF),
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
