import 'package:flutter/material.dart';
import 'package:hydrowflow/core/theme/app_theme.dart';

class BarBuilder {
  static const double maxBarHeight = 120;

  static List<Widget> buildBars({
    required BuildContext context,
    required List<int> cups,
    required List<String> labels,
    required int max,
    int? highlightIndex,
  }) {
    final colors = context.colors;

    return List.generate(cups.length, (i) {
      final h = max == 0 ? 0.0 : (cups[i] / max) * maxBarHeight;
      final highlighted = i == highlightIndex;

      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              cups[i] > 0 ? '${cups[i]}' : '',
              style: TextStyle(
                color: highlighted ? colors.textPrimary : colors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 26,
              height: h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: highlighted
                      ? [colors.primaryLight, colors.primary]
                      : [
                          colors.primary.withValues(alpha: 0.35),
                          colors.primary.withValues(alpha: 0.25),
                        ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              labels[i],
              style: TextStyle(
                color: highlighted ? colors.primary : colors.textMuted,
                fontSize: 11,
                fontWeight: highlighted ? FontWeight.w800 : FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    });
  }
}
