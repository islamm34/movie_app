// lib/domain/auth/repositories/auth_repository.dart

import '../use_case/entities/user_entity.dart';

abstract class AuthRepository {
  // تسجيل الدخول
  Future<UserEntity?> loginWithEmail(String email, String password);
  Future<UserEntity?> loginWithGoogle();

  // التسجيل
  Future<UserEntity?> registerWithEmail(String email, String password, String name, String phone);

  // تسجيل الخروج
  Future<void> logout();

  // التحقق من حالة المستخدم
  Stream<UserEntity?> get user;
  UserEntity? get currentUser;

  // إعادة تعيين كلمة المرور
  Future<bool> resetPassword(String email);

  // تحديث الملف الشخصي
  Future<UserEntity?> updateProfile({String? name, String? photoUrl});
}