// lib/features/ui/auth/widgets/google_auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== Google Sign In ====================

  Future<User?> signInWithGoogle() async {
    try {
      // تهيئة GoogleSignIn
      GoogleSignIn googleSignIn = GoogleSignIn();

      // تسجيل الدخول
      GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      // الحصول على معلومات المصادقة
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // إنشاء بيانات اعتماد Firebase
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // تسجيل الدخول إلى Firebase
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      return userCredential.user;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  // ==================== Email/Password Registration ====================

  Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.sendEmailVerification();
      await _auth.signOut();

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      throw Exception(message);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع. حاول مرة أخرى.');
    }
  }

  // ==================== Email/Password Login ====================

  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      if (!userCredential.user!.emailVerified) {
        throw Exception('يرجى تأكيد بريدك الإلكتروني أولاً. تحقق من صندوق الوارد الخاص بك.');
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      throw Exception(message);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع. حاول مرة أخرى.');
    }
  }

  // ==================== Resend Verification Email ====================

  Future<void> resendVerificationEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      if (!userCredential.user!.emailVerified) {
        await userCredential.user?.sendEmailVerification();
      } else {
        throw Exception('بريدك الإلكتروني مفعل بالفعل');
      }

      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      throw Exception(message);
    }
  }

  // ==================== Password Reset ====================

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      throw Exception(message);
    }
  }

  // ==================== Sign Out ====================

  Future<void> signOut() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await _auth.signOut();
  }

  // ==================== Private Methods ====================

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً (يجب أن تكون 6 أحرف على الأقل)';
      case 'user-not-found':
        return 'المستخدم غير موجود';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'too-many-requests':
        return 'طلبات كثيرة جداً. حاول مرة أخرى لاحقاً';
      case 'network-request-failed':
        return 'خطأ في الشبكة. تحقق من اتصالك بالإنترنت';
      default:
        return 'حدث خطأ. حاول مرة أخرى';
    }
  }

  // ==================== Validation Methods ====================

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'البريد الإلكتروني غير صالح';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (password.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  static String? validateConfirmPassword(
      String? password,
      String? confirmPassword,
      ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }
    if (password != confirmPassword) {
      return 'كلمة المرور غير متطابقة';
    }
    return null;
  }

  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'الاسم مطلوب';
    }
    if (name.length < 3) {
      return 'الاسم يجب أن يكون 3 أحرف على الأقل';
    }
    return null;
  }

  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleanPhone.length < 10) {
      return 'رقم الهاتف غير صالح';
    }
    return null;
  }
}