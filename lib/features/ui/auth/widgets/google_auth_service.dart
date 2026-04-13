// lib/features/ui/auth/widgets/google_auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== Google Sign In ====================

  Future<User?> signInWithGoogle() async {
    try {
      // Initialize GoogleSignIn
      GoogleSignIn googleSignIn = GoogleSignIn();

      // Sign in
      GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      // Get authentication information
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credentials
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
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
      throw Exception('An unexpected error occurred. Try again.');
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
        throw Exception('Please verify your email first. Check your inbox.');
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      throw Exception(message);
    } catch (e) {
      throw Exception('An unexpected error occurred. Try again.');
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
        throw Exception('Your email is already activated');
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
        return 'This email is already in use';
      case 'invalid-email':
        return 'Invalid email';
      case 'weak-password':
        return 'Password is too weak (must be at least 6 characters)';
      case 'user-not-found':
        return 'User not found';
      case 'wrong-password':
        return 'Wrong password';
      case 'too-many-requests':
        return 'Too many requests. Try again later';
      case 'network-request-failed':
        return 'Network error. Check your internet connection';
      default:
        return 'An error occurred. Try again';
    }
  }

  // ==================== Validation Methods ====================

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Invalid email';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(
      String? password,
      String? confirmPassword,
      ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Confirm password is required';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }
    if (name.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Phone number is required';
    }
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleanPhone.length < 10) {
      return 'Invalid phone number';
    }
    return null;
  }
}