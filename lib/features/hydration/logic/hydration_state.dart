import 'package:hydrowflow/features/hydration/data/models/drink_type.dart';
import 'package:hydrowflow/features/hydration/data/models/hydration_log.dart';

class HydrationState {
  final double dailyGoalLiters;
  final int totalCups;
  final int consumedCups;
  final int consumedMl;
  final List<HydrationLog> logs;
  final DrinkType selectedDrink;
  final bool loading;
  final String? error;

  const HydrationState({
    required this.dailyGoalLiters,
    required this.totalCups,
    required this.consumedCups,
    required this.consumedMl,
    required this.logs,
    this.selectedDrink = DrinkType.water,
    this.loading = false,
    this.error,
  });

  factory HydrationState.initial(double dailyGoalLiters) {
    return HydrationState(
      dailyGoalLiters: dailyGoalLiters,
      totalCups: (dailyGoalLiters * 1000 / 250).round(),
      consumedCups: 0,
      consumedMl: 0,
      logs: const [],
    );
  }

  double get progress {
    if (totalCups == 0) return 0;
    return (consumedCups / totalCups).clamp(0.0, 1.0);
  }

  double get progressPercent => (progress * 100).clamp(0.0, 100.0);

  bool get goalReached => consumedCups >= totalCups && totalCups > 0;

  String get motivationMessage {
    final p = progress;
    final hour = DateTime.now().hour;

    if (p == 0) {
      if (hour < 11) return "Good morning! Start with a cup of water 💧";
      return "Let's start hydrating!";
    }
    if (p < 0.3) return "Good start! Keep going 💧";
    if (p < 0.7) return "You're doing great! Stay consistent 🚀";
    if (p < 1) return "Almost there! Keep sipping 🌊";
    return "Goal reached! Amazing job 🎉";
  }

  HydrationState copyWith({
    double? dailyGoalLiters,
    int? totalCups,
    int? consumedCups,
    int? consumedMl,
    List<HydrationLog>? logs,
    DrinkType? selectedDrink,
    bool? loading,
    String? error,
  }) {
    return HydrationState(
      dailyGoalLiters: dailyGoalLiters ?? this.dailyGoalLiters,
      totalCups: totalCups ?? this.totalCups,
      consumedCups: consumedCups ?? this.consumedCups,
      consumedMl: consumedMl ?? this.consumedMl,
      logs: logs ?? this.logs,
      selectedDrink: selectedDrink ?? this.selectedDrink,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}
