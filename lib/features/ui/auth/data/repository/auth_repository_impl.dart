// lib/data/auth/repositories/auth_repository_impl.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/auth_repository.dart';
import '../../use_case/entities/user_entity.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: ['email']);

  @override
  Future<UserEntity?> loginWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      return _convertToUserEntity(userCredential.user);
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  @override
  Future<UserEntity?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await _firebaseAuth.signInWithCredential(credential);

      return _convertToUserEntity(userCredential.user);
    } catch (e) {
      print('Google login error: $e');
      return null;
    }
  }

  @override
  Future<UserEntity?> registerWithEmail(
      String email,
      String password,
      String name,
      String phone,
      ) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update user name
      await userCredential.user?.updateDisplayName(name);

      // Save additional information in Firestore (optional)
      await _saveUserToFirestore(
        userId: userCredential.user!.uid,
        email: email,
        name: name,
        phone: phone,
      );

      // Reload user to get latest data
      await userCredential.user?.reload();
      final updatedUser = _firebaseAuth.currentUser;

      return _convertToUserEntity(updatedUser);
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Stream<UserEntity?> get user => _firebaseAuth.authStateChanges().map(
        (User? user) => _convertToUserEntity(user),
  );

  @override
  UserEntity? get currentUser => _convertToUserEntity(_firebaseAuth.currentUser);

  @override
  Future<bool> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Reset password error: $e');
      return false;
    }
  }

  @override
  Future<UserEntity?> updateProfile({String? name, String? photoUrl}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      if (name != null) {
        await user.updateDisplayName(name);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      await user.reload();
      return _convertToUserEntity(_firebaseAuth.currentUser);
    } catch (e) {
      print('Update profile error: $e');
      return null;
    }
  }

  // Helper method to convert Firebase User to UserEntity
  UserEntity? _convertToUserEntity(User? user) {
    if (user == null) return null;

    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      photoUrl: user.photoURL,
      phone: user.phoneNumber,
      createdAt: user.metadata.creationTime,
    );
  }

  // Save user data in Firestore (optional)
  Future<void> _saveUserToFirestore({
    required String userId,
    required String email,
    required String name,
    required String phone,
  }) async {
    // You can add Firebase Firestore here if you want to save additional data
    // Example:
    // final FirebaseFirestore firestore = FirebaseFirestore.instance;
    // await firestore.collection('users').doc(userId).set({
    //   'email': email,
    //   'name': name,
    //   'phone': phone,
    //   'createdAt': FieldValue.serverTimestamp(),
    // });
  }
}