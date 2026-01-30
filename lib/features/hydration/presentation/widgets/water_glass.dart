import 'package:flutter/material.dart';

class WaterGlass extends StatelessWidget {
  final double progress;

  const WaterGlass({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    const double glassHeight = 250;

    return Container(
      height: glassHeight,
      width: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(46),
        color: const Color(0xFF0F172A),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          /// Water
          Positioned.fill(
            left: 6,
            right: 6,
            bottom: 6,
            top: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(38),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  FractionallySizedBox(
                    heightFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF7DD3FC),
                            Color(0xFF38BDF8),
                            Color(0xFF0284C7),
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// Water surface
                  Positioned(
                    bottom:
                        (progress.clamp(0.0, 1.0) * (glassHeight - 23.1)) - 4,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 12,
                      color: Colors.white.withOpacity(0.35),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Glass outline
          Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(43),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 2,
              ),
            ),
          ),

          /// Shine
          Positioned(
            left: 18,
            top: 28,
            child: Container(
              width: 6,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
