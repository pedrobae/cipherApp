import 'package:cipher_app/models/domain/playlist/playlist_item.dart';

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
