// lib/domain/auth/usecases/reset_password_usecase.dart

import '../domain/auth_repository.dart';
import 'entities/auth_result.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<AuthResult> execute(String email) async {
    try {
      if (email.isEmpty) {
        return AuthResult.failure('Email is required');
      }
      if (!email.contains('@')) {
        return AuthResult.failure('Invalid email format');
      }

      final success = await repository.resetPassword(email);

      if (success) {
        return AuthResult.success(null);
      } else {
        return AuthResult.failure('Failed to send reset email');
      }
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }
}
