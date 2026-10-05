class SubscriptionState {
  final bool isPro;
  final DateTime? trialUntil;
  final bool loading;
  final bool purchasing;
  final String? error;
  final List<String> planLabels;
  final List<int> packageIndexes;

  const SubscriptionState({
    required this.isPro,
    this.trialUntil,
    this.loading = false,
    this.purchasing = false,
    this.error,
    this.planLabels = const [],
    this.packageIndexes = const [],
  });

  factory SubscriptionState.initial() {
    return const SubscriptionState(isPro: false);
  }

  bool get trialActive =>
      trialUntil != null && trialUntil!.isAfter(DateTime.now());

  /// Paid Pro or an active 24h trial earned by watching a rewarded video.
  bool get isPremium => isPro || trialActive;

  SubscriptionState copyWith({
    bool? isPro,
    DateTime? trialUntil,
    bool clearTrial = false,
    bool? loading,
    bool? purchasing,
    String? error,
    List<String>? planLabels,
    List<int>? packageIndexes,
  }) {
    return SubscriptionState(
      isPro: isPro ?? this.isPro,
      trialUntil: clearTrial ? null : (trialUntil ?? this.trialUntil),
      loading: loading ?? this.loading,
      purchasing: purchasing ?? this.purchasing,
      error: error,
      planLabels: planLabels ?? this.planLabels,
      packageIndexes: packageIndexes ?? this.packageIndexes,
    );
  }
}
