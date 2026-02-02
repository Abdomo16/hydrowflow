class NavigationState {
  final int index;

  const NavigationState({required this.index});

  factory NavigationState.initial() {
    return const NavigationState(index: 0);
  }

  NavigationState copyWith({int? index}) {
    return NavigationState(index: index ?? this.index);
  }
}
