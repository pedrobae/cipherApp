import 'package:cipher_app/models/domain/playlist/playlist_item.dart';

class PlaylistItemDto {
  final String type; // 'cipher_version' or 'text_section'
  final String? firebaseContentId; // 'cipherId:versionId' ou textId
  final String? status; // e.g., 'unknown' for placeholders
  final String addedBy; // userId who added the item
  final Map<String, dynamic>? displayFallback; // optional lightweight hints

  PlaylistItemDto({
    required this.type,
    this.firebaseContentId,
    this.status,
    this.displayFallback,
    required this.addedBy,
  });

  factory PlaylistItemDto.fromFirestore(Map<String, dynamic> json) {
    return PlaylistItemDto(
      type: json['type'] as String? ?? '',
      firebaseContentId: json['firebaseContentId'] as String?,
      status: json['status'] as String?,
      addedBy: json['addedBy'] as String? ?? '',
      displayFallback: json['displayFallback'] is Map<String, dynamic>
          ? (json['displayFallback'] as Map<String, dynamic>)
          : (json['displayFallback'] != null
                ? Map<String, dynamic>.from(json['displayFallback'])
                : null),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'firebaseContentId': firebaseContentId,
      'addedBy': addedBy,
      'status': status,
      'displayFallback': displayFallback,
    };
  }

  PlaylistItem toDomain(int position) {
    return PlaylistItem(
      type: type,
      firebaseContentId: firebaseContentId,
      position: position,
    );
  }

  PlaylistItemDto copyWith({
    String? type,
    String? firebaseContentId,
    String? status,
    String? addedBy,
    Map<String, dynamic>? displayFallback,
  }) {
    return PlaylistItemDto(
      type: type ?? this.type,
      firebaseContentId: firebaseContentId ?? this.firebaseContentId,
      addedBy: addedBy ?? this.addedBy,
      status: status ?? this.status,
      displayFallback: displayFallback ?? this.displayFallback,
    );
  }
}
