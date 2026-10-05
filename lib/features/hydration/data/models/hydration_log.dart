import 'drink_type.dart';

class HydrationLog {
  final int? id;
  final String date;
  final int amountMl;
  final DrinkType drinkType;

  /// The part of [amountMl] that counts toward the goal.
  final int hydrationMl;
  final DateTime createdAt;

  HydrationLog({
    this.id,
    required this.date,
    required this.amountMl,
    required this.createdAt,
    this.drinkType = DrinkType.water,
    int? hydrationMl,
  }) : hydrationMl = hydrationMl ?? drinkType.hydrationMl(amountMl);

  factory HydrationLog.fromMap(Map<String, dynamic> map) {
    final amount = map['amount_ml'] as int;
    return HydrationLog(
      id: map['id'] as int?,
      date: map['date'] as String,
      amountMl: amount,
      drinkType: DrinkType.byName(map['drink_type'] as String?),
      hydrationMl: map['hydration_ml'] as int? ?? amount,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'amount_ml': amountMl,
      'drink_type': drinkType.name,
      'hydration_ml': hydrationMl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  HydrationLog copyWith({
    int? id,
    String? date,
    int? amountMl,
    DrinkType? drinkType,
    int? hydrationMl,
    DateTime? createdAt,
  }) {
    return HydrationLog(
      id: id ?? this.id,
      date: date ?? this.date,
      amountMl: amountMl ?? this.amountMl,
      drinkType: drinkType ?? this.drinkType,
      hydrationMl: hydrationMl ?? this.hydrationMl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
