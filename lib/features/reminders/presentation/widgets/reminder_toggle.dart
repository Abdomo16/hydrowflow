import 'package:flutter/material.dart';

class ReminderToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ReminderToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16202A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF223A55),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Smart Reminders',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.blue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
