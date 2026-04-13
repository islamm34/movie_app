// lib/domain/auth/usecases/login_with_google_usecase.dart

import '../domain/auth_repository.dart';
import 'entities/auth_result.dart';

class LoginWithGoogleUseCase {
  final AuthRepository repository;

  LoginWithGoogleUseCase(this.repository);

  Future<AuthResult> execute() async {
    try {
      final user = await repository.loginWithGoogle();

      if (user != null) {
        return AuthResult.success(user);
      } else {
        return AuthResult.failure('Google login cancelled');
      }
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }
}
