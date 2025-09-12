import 'package:flutter/material.dart';
import '../../helpers/datetime.dart';

/// Represents a user who contributes to a playlist with their musical role
class Collaborator {
  final int id;
  final int userId;
  final int playlistId;
  final String instrument; // 'guitarist', 'vocalist', 'drummer', etc.
  final int addedBy;
  final DateTime? addedAt;

  // User details (joined from user table)
  final String? username;
  final String? email;
  final String? profilePhoto;

  const Collaborator({
    required this.id,
    required this.userId,
    required this.playlistId,
    required this.instrument,
    required this.addedBy,
    this.addedAt,
    this.username,
    this.email,
    this.profilePhoto,
  });

  factory Collaborator.fromJson(Map<String, dynamic> json) {
    return Collaborator(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      playlistId: json['playlist_id'] as int,
      instrument:
          json['role'] as String, // 'role' field stores instrument in DB
      addedBy: json['added_by'] as int,
      addedAt: DatetimeHelper.parseDateTime(json['added_at']),
      username: json['username'] as String?,
      email: json['mail'] as String?,
      profilePhoto: json['profile_photo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'playlist_id': playlistId,
      'role': instrument, // Store instrument in 'role' field
      'added_by': addedBy,
      'added_at': addedAt?.toIso8601String(),
    };
  }

  Collaborator copyWith({
    int? id,
    int? userId,
    int? playlistId,
    String? instrument,
    int? addedBy,
    DateTime? addedAt,
    String? username,
    String? email,
    String? profilePhoto,
  }) {
    return Collaborator(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      playlistId: playlistId ?? this.playlistId,
      instrument: instrument ?? this.instrument,
      addedBy: addedBy ?? this.addedBy,
      addedAt: addedAt ?? this.addedAt,
      username: username ?? this.username,
      email: email ?? this.email,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }

  // Helper method to get appropriate instrument icon
  IconData get instrumentIcon {
    switch (instrument.toLowerCase()) {
      case 'guitarrista':
      case 'guitar':
      case 'guitarist':
        return Icons.music_note;
      case 'vocalista':
      case 'vocal':
      case 'vocalist':
        return Icons.mic;
      case 'baterista':
      case 'drums':
      case 'drummer':
        return Icons.upcoming;
      case 'baixista':
      case 'bass':
      case 'bassist':
        return Icons.queue_music;
      case 'tecladista':
      case 'keyboard':
      case 'keyboardist':
        return Icons.piano;
      default:
        return Icons.person;
    }
  }
}
