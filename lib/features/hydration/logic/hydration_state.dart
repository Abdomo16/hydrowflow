class HydrationState {
  final double dailyGoalLiters;
  final int totalCups;
  final int consumedCups;

  const HydrationState({
    required this.dailyGoalLiters,
    required this.totalCups,
    required this.consumedCups,
  });

  double get progress {
    if (totalCups == 0) return 0;
    return consumedCups / totalCups;
  }

  HydrationState copyWith({
    double? dailyGoalLiters,
    int? totalCups,
    int? consumedCups,
  }) {
    return HydrationState(
      dailyGoalLiters: dailyGoalLiters ?? this.dailyGoalLiters,
      totalCups: totalCups ?? this.totalCups,
      consumedCups: consumedCups ?? this.consumedCups,
    );
  }
}
