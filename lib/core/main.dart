import 'package:flutter/material.dart';
import 'package:hydrowflow/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Inter'),
      home: Scaffold(backgroundColor: Colors.white, body: OnboardingScreen()),
    );
  }
}
