// lib/domain/auth/usecases/login_with_email_usecase.dart

import '../domain/auth_repository.dart';
import 'entities/auth_result.dart';

class LoginWithEmailUseCase {
  final AuthRepository repository;

  LoginWithEmailUseCase(this.repository);

  Future<AuthResult> execute(String email, String password) async {
    try {
      if (email.isEmpty) {
        return AuthResult.failure('Email is required');
      }
      if (password.isEmpty) {
        return AuthResult.failure('Password is required');
      }
      if (!email.contains('@')) {
        return AuthResult.failure('Invalid email format');
      }
      if (password.length < 6) {
        return AuthResult.failure('Password must be at least 6 characters');
      }

      final user = await repository.loginWithEmail(email, password);

      if (user != null) {
        return AuthResult.success(user);
      } else {
        return AuthResult.failure('Login failed');
      }
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }
}
