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

  HydrationState copyWith({int? consumedCups}) {
    return HydrationState(
      dailyGoalLiters: dailyGoalLiters,
      totalCups: totalCups,
      consumedCups: consumedCups ?? this.consumedCups,
    );
  }
}
