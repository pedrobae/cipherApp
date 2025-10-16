import 'package:cipher_app/models/domain/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDto {
  final String? firebaseId;
  final String username;
  final String mail;
  final String? profilePhoto;
  final String? googleId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const UserDto({
    this.firebaseId,
    required this.username,
    required this.mail,
    this.profilePhoto,
    this.googleId,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory UserDto.fromFirestore(Map<String, dynamic> json, String id) {
    return UserDto(
      firebaseId: id,
      username: json['username'] as String,
      mail: json['mail'] as String,
      profilePhoto: json['profilePhoto'] as String?,
      googleId: json['googleId'] as String?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      isActive: (json['isActive'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'mail': mail,
      'profilePhoto': profilePhoto,
      'googleId': googleId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt':
          FieldValue.serverTimestamp(), // Server timestamp to avoid client clock issues
      'isActive': isActive,
    };
  }

  User toDomain() {
    return User(
      firebaseId: firebaseId!,
      username: username,
      mail: mail,
      profilePhoto: profilePhoto,
      googleId: googleId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
    );
  }

  UserDto copyWith({
    String? firebaseId,
    String? username,
    String? mail,
    String? profilePhoto,
    String? googleId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserDto(
      firebaseId: firebaseId ?? this.firebaseId,
      username: username ?? this.username,
      mail: mail ?? this.mail,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      googleId: googleId ?? this.googleId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
