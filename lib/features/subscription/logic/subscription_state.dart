class SubscriptionState {
  final bool isPro;
  final bool loading;
  final bool purchasing;
  final String? error;
  final List<String> planLabels;
  final List<int> packageIndexes;

  const SubscriptionState({
    required this.isPro,
    this.loading = false,
    this.purchasing = false,
    this.error,
    this.planLabels = const [],
    this.packageIndexes = const [],
  });

  factory SubscriptionState.initial() {
    return const SubscriptionState(isPro: false);
  }

  SubscriptionState copyWith({
    bool? isPro,
    bool? loading,
    bool? purchasing,
    String? error,
    List<String>? planLabels,
    List<int>? packageIndexes,
  }) {
    return SubscriptionState(
      isPro: isPro ?? this.isPro,
      loading: loading ?? this.loading,
      purchasing: purchasing ?? this.purchasing,
      error: error,
      planLabels: planLabels ?? this.planLabels,
      packageIndexes: packageIndexes ?? this.packageIndexes,
    );
  }
}
