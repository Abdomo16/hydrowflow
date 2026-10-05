class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;

  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isAnonymous = false,
  });

  factory AuthUser.fromFirebase(dynamic user) {
    return AuthUser(
      uid: user.uid as String,
      email: user.email as String?,
      displayName: user.displayName as String?,
      photoUrl: user.photoURL as String?,
      isAnonymous: user.isAnonymous as bool? ?? false,
    );
  }
}

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final bool loading;
  final String? error;

  const AuthState({
    required this.status,
    this.user,
    this.loading = false,
    this.error,
  });

  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.unknown);
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    bool? loading,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}
