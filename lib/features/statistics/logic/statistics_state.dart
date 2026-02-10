enum StatsView { week, month }

class StatisticsState {
  final StatsView view;
  final int streak;
  final List<int> weeklyCups;
  final List<int> monthlyCups;
  final double hydrationScore;
  final double avgMonthly;
  final double completionRate;
  final String bestDay;
  final bool loading;

  const StatisticsState({
    required this.view,
    required this.streak,
    required this.weeklyCups,
    required this.monthlyCups,
    required this.hydrationScore,
    required this.avgMonthly,
    required this.completionRate,
    required this.bestDay,
    required this.loading,
  });

  factory StatisticsState.initial() {
    return const StatisticsState(
      view: StatsView.week,
      streak: 0,
      weeklyCups: [0, 0, 0, 0, 0, 0, 0],
      monthlyCups: [0, 0, 0, 0],
      hydrationScore: 0,
      avgMonthly: 0,
      completionRate: 0,
      bestDay: '-',
      loading: true,
    );
  }

  StatisticsState copyWith({
    StatsView? view,
    int? streak,
    List<int>? weeklyCups,
    List<int>? monthlyCups,
    double? hydrationScore,
    double? avgMonthly,
    double? completionRate,
    String? bestDay,
    bool? loading,
  }) {
    return StatisticsState(
      view: view ?? this.view,
      streak: streak ?? this.streak,
      weeklyCups: weeklyCups ?? this.weeklyCups,
      monthlyCups: monthlyCups ?? this.monthlyCups,
      hydrationScore: hydrationScore ?? this.hydrationScore,
      avgMonthly: avgMonthly ?? this.avgMonthly,
      completionRate: completionRate ?? this.completionRate,
      bestDay: bestDay ?? this.bestDay,
      loading: loading ?? this.loading,
    );
  }
}
