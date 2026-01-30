import 'package:flutter/material.dart';

class HydrationScreen extends StatelessWidget {
  final double dailyGoal; // 👈 الرقم اللي اتحسب

  const HydrationScreen({super.key, required this.dailyGoal});

  @override
  Widget build(BuildContext context) {
    debugPrint('🔥 dailyGoal = $dailyGoal');

    return Scaffold(
      backgroundColor: const Color(0xFF0E1621),
      body: Center(
        child: Text(
          'GOAL >>> $dailyGoal',
          style: const TextStyle(
            color: Colors.red,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
