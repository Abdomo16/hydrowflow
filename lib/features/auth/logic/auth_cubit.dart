import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  AuthCubit(this.repository) : super(AuthState.initial()) {
    _listenAuthChanges();
  }

  void _listenAuthChanges() {
    repository.authStateChanges.listen((user) {
      if (user != null) {
        emit(
          AuthState(
            status: AuthStatus.authenticated,
            user: AuthUser.fromFirebase(user),
          ),
        );
      } else {
        emit(const AuthState(status: AuthStatus.unauthenticated));
      }
    });
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await repository.signInWithGoogle();
      // Auth state listener emits authenticated state.
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: _friendlyError(e),
        ),
      );
    }
  }

  Future<void> signInWithApple() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await repository.signInWithApple();
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: _friendlyError(e),
        ),
      );
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await repository.signInWithEmail(email, password);
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: _friendlyError(e),
        ),
      );
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await repository.signUpWithEmail(email, password);
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: _friendlyError(e),
        ),
      );
    }
  }

  Future<void> sendPasswordReset(String email) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await repository.sendPasswordReset(email);
      emit(
        state.copyWith(
          loading: false,
          error: 'Password reset email sent. Check your inbox.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: _friendlyError(e),
        ),
      );
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(loading: true));
    await repository.signOut();
  }

  Future<void> deleteAccount() async {
    emit(state.copyWith(loading: true));
    try {
      await repository.deleteAccount();
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Could not delete account. Sign in again and retry.',
        ),
      );
    }
  }

  String _friendlyError(Object e) {
    final message = e.toString();
    if (message.contains('network')) {
      return 'Network error. Check your connection.';
    }
    if (message.contains('invalid-credential') ||
        message.contains('wrong-password') ||
        message.contains('user-not-found')) {
      return 'Incorrect email or password.';
    }
    if (message.contains('email-already-in-use')) {
      return 'An account already exists with this email.';
    }
    if (message.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters.';
    }
    if (message.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }
    if (message.contains('cancelled') || message.contains('Canceled')) {
      return 'Sign in was cancelled.';
    }
    return 'Sign in failed. Please try again.';
  }
}
