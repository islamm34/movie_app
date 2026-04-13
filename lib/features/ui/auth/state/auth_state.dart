import '../use_case/entities/user_entity.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({required this.status, this.user, this.errorMessage});

  // الحالة الأولية
  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  // حالة التحميل
  factory AuthState.loading() {
    return const AuthState(status: AuthStatus.loading);
  }

  // حالة تسجيل الدخول
  factory AuthState.authenticated(UserEntity user) {
    return AuthState(status: AuthStatus.authenticated, user: user);
  }

  // حالة عدم تسجيل الدخول
  factory AuthState.unauthenticated() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  // حالة الخطأ
  factory AuthState.error(String message) {
    return AuthState(status: AuthStatus.error, errorMessage: message);
  }

  // نسخة من الحالة
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
