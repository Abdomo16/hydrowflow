class HydrationLog {
  final int? id;
  final String date;
  final int amountMl;
  final DateTime createdAt;

  const HydrationLog({
    this.id,
    required this.date,
    required this.amountMl,
    required this.createdAt,
  });

  factory HydrationLog.fromMap(Map<String, dynamic> map) {
    return HydrationLog(
      id: map['id'] as int?,
      date: map['date'] as String,
      amountMl: map['amount_ml'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'amount_ml': amountMl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  HydrationLog copyWith({
    int? id,
    String? date,
    int? amountMl,
    DateTime? createdAt,
  }) {
    return HydrationLog(
      id: id ?? this.id,
      date: date ?? this.date,
      amountMl: amountMl ?? this.amountMl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
