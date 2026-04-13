// lib/domain/auth/entities/user_entity.dart

class UserEntity {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? photoUrl;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.photoUrl,
    this.createdAt,
  });

  // Copy of the object with some fields modified
  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Convert from JSON
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}