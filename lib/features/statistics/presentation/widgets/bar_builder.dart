import 'package:flutter/material.dart';

class BarBuilder {
  static List<Widget> buildBars({
    required List<int> cups,
    required List<String> labels,
    required int max,
  }) {
    return List.generate(cups.length, (i) {
      final h = max == 0 ? 0.0 : (cups[i] / max) * 120;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            /// Bar
            Container(
              width: 30,
              height: h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF5DB4FF), Color(0xFF2F8BEF)],
                ),
              ),
            ),

            const SizedBox(height: 8),

            /// Label
            SizedBox(
              width: 30,
              child: Center(
                child: Text(
                  labels[i],
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
