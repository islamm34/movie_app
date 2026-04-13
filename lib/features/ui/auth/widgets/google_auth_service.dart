// lib/features/ui/auth/widgets/google_auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/user_model/model.dart' show UserModel;
import '../data/user_model/user_service.dart';


class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  // ==================== Save Email for Sign-In ====================

  Future<void> _saveEmailForSignIn(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('emailForSignIn', email);
  }


  Future<void> _clearEmailForSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('emailForSignIn');
  }

  // ==================== Send Email Link for Sign-In ====================

  Future<void> sendSignInLinkToEmail({
    required String email,
    required String androidPackageName,
    required String iosBundleId,
    required String url,
  }) async {
    try {
      ActionCodeSettings actionCodeSettings = ActionCodeSettings(
        url: url,
        handleCodeInApp: true,
        androidPackageName: androidPackageName,
        androidMinimumVersion: '12',
        iOSBundleId: iosBundleId,
      );

      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      await _saveEmailForSignIn(email);
    } catch (e) {
      throw Exception('فشل إرسال رابط تسجيل الدخول: $e');
    }
  }

  // ==================== Sign In with Email Link ====================

  Future<User?> signInWithEmailLink(String email, String link) async {
    try {
      if (_auth.isSignInWithEmailLink(link)) {
        final UserCredential userCredential = await _auth.signInWithEmailLink(
          email: email,
          emailLink: link,
        );

        // حفظ المستخدم في Firestore إذا كان جديداً
        final userExists = await _userService.userExists(userCredential.user!.uid);
        if (!userExists) {
          final userModel = UserModel(
            id: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            name: userCredential.user!.displayName ?? '',
            phone: '',
            createdAt: DateTime.now(),
          );
          await _userService.saveUser(userModel);
        }

        await _clearEmailForSignIn();
        return userCredential.user;
      } else {
        throw Exception('الرابط غير صالح لتسجيل الدخول');
      }
    } catch (e) {
      throw Exception('فشل تسجيل الدخول: $e');
    }
  }

  // ==================== Google Sign In ====================

  Future<User?> signInWithGoogle({String? fcmToken}) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      final userExists = await _userService.userExists(userCredential.user!.uid);

      if (!userExists) {
        final userModel = UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          name: userCredential.user!.displayName ?? '',
          phone: '',
          createdAt: DateTime.now(),
          fcmToken: fcmToken,
        );
        await _userService.saveUser(userModel);
      } else {
        await _userService.updateLastLogin(userCredential.user!.uid);
        if (fcmToken != null) {
          await _userService.updateFCMToken(userCredential.user!.uid, fcmToken);
        }
      }

      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  // ==================== Email/Password Registration ====================

  Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    String? fcmToken,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.sendEmailVerification();

      final userModel = UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        phone: phone,
        createdAt: DateTime.now(),
        fcmToken: fcmToken,
      );

      await _userService.saveUser(userModel);

      // ✅ تم التعليق - لا نسجل الخروج بعد التسجيل
      // await _auth.signOut();

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
    String? fcmToken,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      // ✅ تم التعليق مؤقتاً للسماح بتسجيل الدخول حتى لو لم يتم تأكيد البريد
      // if (!userCredential.user!.emailVerified) {
      //   throw Exception('يرجى تأكيد بريدك الإلكتروني أولاً.');
      // }

      await _userService.updateLastLogin(userCredential.user!.uid);
      if (fcmToken != null) {
        await _userService.updateFCMToken(userCredential.user!.uid, fcmToken);
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
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await _auth.signOut();
  }

  // ==================== Get Current User ====================

  User? getCurrentUser() => _auth.currentUser;

  Future<UserModel?> getCurrentUserData() async {
    return await _userService.getCurrentUser();
  }

  // ==================== Update User Profile ====================

  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (name != null) {
        updates['name'] = name;
        await _auth.currentUser?.updateDisplayName(name);
      }
      if (phone != null) updates['phone'] = phone;
      if (photoUrl != null) {
        updates['photoUrl'] = photoUrl;
        await _auth.currentUser?.updatePhotoURL(photoUrl);
      }

      if (updates.isNotEmpty) {
        await _userService.updateUser(userId, updates);
      }
    } catch (e) {
      throw Exception('فشل تحديث الملف الشخصي');
    }
  }

  // ==================== Update FCM Token ====================

  Future<void> updateFCMToken(String token) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _userService.updateFCMToken(user.uid, token);
    }
  }

  // ==================== Delete Account ====================

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _userService.deleteUser(user.uid);
        await user.delete();
      }
    } catch (e) {
      throw Exception('فشل حذف الحساب. يرجى تسجيل الدخول مرة أخرى.');
    }
  }

  // ==================== Check Email Verification Status ====================

  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      return user.emailVerified;
    }
    return false;
  }

  // ==================== Private Methods ====================

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
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
    if (email == null || email.isEmpty) return 'البريد الإلكتروني مطلوب';
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) return 'البريد الإلكتروني غير صالح';
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) return 'كلمة المرور مطلوبة';
    if (password.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    return null;
  }

  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) return 'تأكيد كلمة المرور مطلوب';
    if (password != confirmPassword) return 'كلمة المرور غير متطابقة';
    return null;
  }

  static String? validateName(String? name) {
    if (name == null || name.isEmpty) return 'الاسم مطلوب';
    if (name.length < 3) return 'الاسم يجب أن يكون 3 أحرف على الأقل';
    return null;
  }

  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) return 'رقم الهاتف مطلوب';
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleanPhone.length < 10) return 'رقم الهاتف غير صالح';
    return null;
  }
}