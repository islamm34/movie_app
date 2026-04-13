import '../domain/auth_repository.dart';
import 'entities/auth_result.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<AuthResult> execute({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      // التحقق من صحة البيانات
      if (email.isEmpty) {
        return AuthResult.failure('Email is required');
      }
      if (password.isEmpty) {
        return AuthResult.failure('Password is required');
      }
      if (name.isEmpty) {
        return AuthResult.failure('Name is required');
      }
      if (phone.isEmpty) {
        return AuthResult.failure('Phone number is required');
      }
      if (!email.contains('@')) {
        return AuthResult.failure('Invalid email format');
      }
      if (password.length < 6) {
        return AuthResult.failure('Password must be at least 6 characters');
      }

      final user = await repository.registerWithEmail(
        email,
        password,
        name,
        phone,
      );

      if (user != null) {
        return AuthResult.success(user);
      } else {
        return AuthResult.failure('Registration failed');
      }
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }
}
