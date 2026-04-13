import 'user_entity.dart';

class AuthResult {
  final bool success;
  final UserEntity? user;
  final String? errorMessage;
  const AuthResult({required this.success, this.user, this.errorMessage});
  factory AuthResult.success(UserEntity? user) {
    return AuthResult(success: true, user: user);
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult(success: false, errorMessage: errorMessage);
  }
}
