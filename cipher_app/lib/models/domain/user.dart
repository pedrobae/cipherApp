import '../../helpers/datetime_helper.dart';

class User {
  final int id;
  final String username;
  final String mail;
  final String? profilePhoto;
  final String? googleId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const User({
    required this.id,
    required this.username,
    required this.mail,
    this.profilePhoto,
    this.googleId,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      mail: json['mail'] as String,
      profilePhoto: json['profile_photo'] as String?,
      googleId: json['google_id'] as String?,
      createdAt: DatetimeHelper.parseDateTime(json['created_at']),
      updatedAt: DatetimeHelper.parseDateTime(json['updated_at']),
      isActive: (json['is_active'] as int? ?? 1) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'mail': mail,
      'profile_photo': profilePhoto,
      'google_id': googleId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? mail,
    String? profilePhoto,
    String? googleId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
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