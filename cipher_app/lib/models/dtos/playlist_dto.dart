import 'package:cipher_app/models/domain/playlist/playlist.dart';
import 'package:cipher_app/models/domain/playlist/playlist_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlaylistDto {
  final String? firebaseId; // ID na nuvem (Firebase)
  final String name;
  final String description;
  final String ownerId; // Usuário que criou a playlist
  final bool isPublic;
  final DateTime updatedAt;
  final DateTime createdAt;
  final List<String> collaborators; // userIds

  const PlaylistDto({
    this.firebaseId,
    required this.name,
    required this.description,
    required this.ownerId,
    this.isPublic = false,
    required this.updatedAt,
    required this.createdAt,
    this.collaborators = const [],
  });

  factory PlaylistDto.fromFirestore(Map<String, dynamic> json, String id) {
    return PlaylistDto(
      firebaseId: id,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      isPublic: json['isPublic'] as bool? ?? false,
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      collaborators: List<String>.from(json['collaborators'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'isPublic': isPublic,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdAt': Timestamp.fromDate(createdAt),
      'collaborators': collaborators,
    };
  }

  Playlist toDomain(List<PlaylistItem> items) {
    return Playlist(
      id: -1, // ID local será atribuído pelo banco de dados local
      name: name,
      description: description,
      createdBy: ownerId,
      isPublic: isPublic,
      updatedAt: updatedAt,
      createdAt: createdAt,
      collaborators: collaborators,
      items: items,
      firebaseId: firebaseId,
    );
  }
}

class PlaylistItemDto {
  final String id;
  final String type; // 'cipher_version' or 'text_section'
  final String? firebaseContentId;
  int? position;
  final String? status; // e.g., 'unknown' for placeholders
  final Map<String, dynamic>? displayFallback; // optional lightweight hints

  PlaylistItemDto({
    required this.id,
    required this.type,
    this.firebaseContentId,
    this.position,
    this.status,
    this.displayFallback,
  });

  factory PlaylistItemDto.fromFirestore(Map<String, dynamic> json, String id) {
    return PlaylistItemDto(
      id: id,
      type: json['type'] as String? ?? '',
      firebaseContentId: json['firebaseContentId'] as String?,
      position: json['position'] as int?,
      status: json['status'] as String?,
      displayFallback: json['displayFallback'] is Map<String, dynamic>
          ? (json['displayFallback'] as Map<String, dynamic>)
          : (json['displayFallback'] != null
              ? Map<String, dynamic>.from(json['displayFallback'])
              : null),
    );
  }

  Map<String, dynamic> toFirestore(String playlistId) {
    return {
      'playlistId': playlistId,
      'type': type,
      'firebaseContentId': firebaseContentId,
      'position': position,
      if (status != null) 'status': status,
      if (displayFallback != null) 'displayFallback': displayFallback,
    };
  }

  PlaylistItem toDomain() {
    return PlaylistItem(
      type: type,
      position: position!,
      firebaseId: id,
      firebaseContentId: firebaseContentId,
    );
  }

  PlaylistItemDto copyWith({
    String? type,
    String? firebaseContentId,
    int? position,
    String? status,
    Map<String, dynamic>? displayFallback,
  }) {
    return PlaylistItemDto(
      id: id,
      type: type ?? this.type,
      firebaseContentId: firebaseContentId ?? this.firebaseContentId,
      position: position ?? this.position,
      status: status ?? this.status,
      displayFallback: displayFallback ?? this.displayFallback,
    );
  }
}
