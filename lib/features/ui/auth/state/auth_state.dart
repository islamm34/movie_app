import '../use_case/entities/user_entity.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({required this.status, this.user, this.errorMessage});

  // Initial state
  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  // Loading state
  factory AuthState.loading() {
    return const AuthState(status: AuthStatus.loading);
  }

  // Login state
  factory AuthState.authenticated(UserEntity user) {
    return AuthState(status: AuthStatus.authenticated, user: user);
  }

  // Not logged in state
  factory AuthState.unauthenticated() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  // Error state
  factory AuthState.error(String message) {
    return AuthState(status: AuthStatus.error, errorMessage: message);
  }

  // Copy of the state
  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
