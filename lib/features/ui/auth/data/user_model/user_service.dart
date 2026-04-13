// lib/core/services/user_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // الحصول على مرجع المجموعة
  CollectionReference get _usersCollection => _firestore.collection('users');

  // حفظ مستخدم جديد
  Future<void> saveUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toJson());
      print('✅ User saved to Firestore: ${user.email}');
    } catch (e) {
      print('❌ Error saving user: $e');
      throw Exception('فشل حفظ بيانات المستخدم: $e');
    }
  }

  // تحديث بيانات المستخدم
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(userId).update(data);
      print('✅ User updated: $userId');
    } catch (e) {
      print('❌ Error updating user: $e');
      throw Exception('فشل تحديث بيانات المستخدم: $e');
    }
  }

  // تحديث الاسم
  Future<void> updateName(String userId, String name) async {
    await updateUser(userId, {'name': name});
  }

  // تحديث رقم الهاتف
  Future<void> updatePhone(String userId, String phone) async {
    await updateUser(userId, {'phone': phone});
  }

  // تحديث FCM Token
  Future<void> updateFCMToken(String userId, String token) async {
    await updateUser(userId, {'fcmToken': token});
  }

  // تحديث آخر تسجيل دخول
  Future<void> updateLastLogin(String userId) async {
    await updateUser(userId, {'lastLoginAt': DateTime.now().toIso8601String()});
  }

  // الحصول على مستخدم
  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(userId).get();

      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user: $e');
      return null;
    }
  }

  // الحصول على المستخدم الحالي
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await getUser(user.uid);
  }

  // التحقق من وجود المستخدم
  Future<bool> userExists(String userId) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(userId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // إضافة فيلم إلى المفضلة
  Future<void> addToFavorites(String userId, String movieId) async {
    try {
      await _usersCollection.doc(userId).update({
        'favoriteMovies': FieldValue.arrayUnion([movieId]),
      });
      print('✅ Added to favorites: $movieId');
    } catch (e) {
      print('❌ Error adding to favorites: $e');
    }
  }

  // إزالة فيلم من المفضلة
  Future<void> removeFromFavorites(String userId, String movieId) async {
    try {
      await _usersCollection.doc(userId).update({
        'favoriteMovies': FieldValue.arrayRemove([movieId]),
      });
      print('✅ Removed from favorites: $movieId');
    } catch (e) {
      print('❌ Error removing from favorites: $e');
    }
  }

  // إضافة فيلم إلى قائمة المشاهدة
  Future<void> addToWatchlist(String userId, String movieId) async {
    try {
      await _usersCollection.doc(userId).update({
        'watchlist': FieldValue.arrayUnion([movieId]),
      });
      print('✅ Added to watchlist: $movieId');
    } catch (e) {
      print('❌ Error adding to watchlist: $e');
    }
  }

  // إزالة فيلم من قائمة المشاهدة
  Future<void> removeFromWatchlist(String userId, String movieId) async {
    try {
      await _usersCollection.doc(userId).update({
        'watchlist': FieldValue.arrayRemove([movieId]),
      });
      print('✅ Removed from watchlist: $movieId');
    } catch (e) {
      print('❌ Error removing from watchlist: $e');
    }
  }

  // التحقق من وجود فيلم في المفضلة
  Future<bool> isFavorite(String userId, String movieId) async {
    try {
      final user = await getUser(userId);
      return user?.favoriteMovies?.contains(movieId) ?? false;
    } catch (e) {
      return false;
    }
  }

  // حذف حساب المستخدم
  Future<void> deleteUser(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
      await _auth.currentUser?.delete();
      print('✅ User deleted: $userId');
    } catch (e) {
      print('❌ Error deleting user: $e');
      throw Exception('فشل حذف الحساب: $e');
    }
  }
}