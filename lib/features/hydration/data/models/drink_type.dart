import 'package:flutter/material.dart';

/// How much of a drink counts toward the water goal. Water is free; the
/// others are Premium.
enum DrinkType {
  water('Water', Icons.water_drop, 1.0),
  sparkling('Sparkling', Icons.bubble_chart, 1.0),
  tea('Tea', Icons.emoji_food_beverage, 0.9),
  milk('Milk', Icons.local_drink, 0.9),
  juice('Juice', Icons.local_bar, 0.9),
  coffee('Coffee', Icons.local_cafe, 0.8),
  soda('Soda', Icons.liquor, 0.8);

  final String label;
  final IconData icon;
  final double hydrationFactor;

  const DrinkType(this.label, this.icon, this.hydrationFactor);

  bool get isFree => this == water;

  int hydrationMl(int amountMl) => (amountMl * hydrationFactor).round();

  static DrinkType byName(String? name) => DrinkType.values.firstWhere(
    (t) => t.name == name,
    orElse: () => water,
  );
}
