import 'package:flutter/material.dart';

class ProfileInputCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String unit;
  final Function(String) onChanged;

  const ProfileInputCard({
    super.key,
    required this.label,
    required this.controller,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2633),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF3A8DFF).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(border: InputBorder.none),
                  onChanged: onChanged,
                ),
              ),
              Text(
                unit,
                style: const TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
