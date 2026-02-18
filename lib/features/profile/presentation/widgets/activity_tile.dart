import 'package:flutter/material.dart';
import '../../../onboarding/data/models/onboarding_model.dart';

class ActivityTileWidget extends StatelessWidget {
  final ActivityLevel level;
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const ActivityTileWidget({
    super.key,
    required this.level,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      height: 73,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF1E3A5F) : const Color(0xFF16202A),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: selected ? const Color(0xFF3A8DFF) : Colors.transparent,
          width: 1.3,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: const Color(0xFF3A8DFF).withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 40,
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 23, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        getSubtitle(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 20,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getSubtitle() {
    switch (level) {
      case ActivityLevel.low:
        return "Little or no exercise";
      case ActivityLevel.medium:
        return "Exercise 2–4 days per week";
      case ActivityLevel.high:
        return "Daily intense activity";
    }
  }
}
