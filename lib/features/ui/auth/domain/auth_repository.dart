// lib/domain/auth/repositories/auth_repository.dart

import '../use_case/entities/user_entity.dart';

abstract class AuthRepository {
  // Login
  Future<UserEntity?> loginWithEmail(String email, String password);
  Future<UserEntity?> loginWithGoogle();

  // Registration
  Future<UserEntity?> registerWithEmail(String email, String password, String name, String phone);

  // Logout
  Future<void> logout();

  // Check user status
  Stream<UserEntity?> get user;
  UserEntity? get currentUser;

  // Reset password
  Future<bool> resetPassword(String email);

  // Update profile
  Future<UserEntity?> updateProfile({String? name, String? photoUrl});
}