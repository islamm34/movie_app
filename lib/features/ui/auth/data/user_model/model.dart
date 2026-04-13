// lib/data/auth/models/user_model.dart

import '../../use_case/entities/user_entity.dart';

class UserModel extends UserEntity {
  final String? fcmToken;
  final DateTime? lastLoginAt;
  final List<String>? favoriteMovies;
  final List<String>? watchlist;

  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.phone,
    super.photoUrl,
    super.createdAt,
    this.fcmToken,
    this.lastLoginAt,
    this.favoriteMovies,
    this.watchlist,
  });

  // Convert from JSON (for Firestore)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      fcmToken: json['fcmToken'] as String?,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      favoriteMovies: json['favoriteMovies'] != null
          ? List<String>.from(json['favoriteMovies'] as List)
          : null,
      watchlist: json['watchlist'] != null
          ? List<String>.from(json['watchlist'] as List)
          : null,
    );
  }

  // Convert to JSON (for Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'createdAt': createdAt?.toIso8601String(),
      'fcmToken': fcmToken,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'favoriteMovies': favoriteMovies ?? [],
      'watchlist': watchlist ?? [],
    };
  }

  // Convert from UserEntity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      phone: entity.phone,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
    );
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? photoUrl,
    DateTime? createdAt,
    String? fcmToken,
    DateTime? lastLoginAt,
    List<String>? favoriteMovies,
    List<String>? watchlist,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      favoriteMovies: favoriteMovies ?? this.favoriteMovies,
      watchlist: watchlist ?? this.watchlist,
    );
  }
}