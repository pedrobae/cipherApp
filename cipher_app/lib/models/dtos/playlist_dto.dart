import 'package:cipher_app/models/domain/playlist/playlist.dart';
import 'package:cipher_app/models/domain/playlist/playlist_item.dart';
import 'package:cipher_app/models/dtos/playlist_item_dto.dart';
import 'package:cipher_app/helpers/firestore_timestamp_helper.dart';

class PlaylistDto {
  final String? firebaseId; // ID na nuvem (Firebase)
  final String name;
  final String description;
  final String ownerId; // Usuário que criou a playlist
  final bool isPublic;
  final DateTime updatedAt;
  final DateTime createdAt;
  final List<Map<String, dynamic>>
  collaborators; // {'id': String, 'role': String}
  final List<PlaylistItemDto>
  items; // Array whose order matters (order of items)

  const PlaylistDto({
    this.firebaseId,
    required this.name,
    required this.description,
    required this.ownerId,
    this.isPublic = false,
    required this.updatedAt,
    required this.createdAt,
    this.collaborators = const [],
    this.items = const [],
  });

  factory PlaylistDto.fromFirestore(Map<String, dynamic> json, String id) {
    return PlaylistDto(
      firebaseId: id,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      isPublic: json['isPublic'] as bool? ?? false,
      updatedAt:
          FirestoreTimestampHelper.toDateTime(json['updatedAt']) ??
          DateTime.now(),
      createdAt:
          FirestoreTimestampHelper.toDateTime(json['createdAt']) ??
          DateTime.now(),
      collaborators: List<Map<String, dynamic>>.from(
        json['collaborators'] ?? [],
      ),
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (item) =>
                    PlaylistItemDto.fromFirestore(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'isPublic': isPublic,
      'updatedAt': FirestoreTimestampHelper.fromDateTime(updatedAt),
      'createdAt': FirestoreTimestampHelper.fromDateTime(createdAt),
      'collaborators': collaborators,
      'items': items.map((item) => item.toFirestore()).toList(),
    };
  }

  Playlist toDomain(List<PlaylistItem> items, int ownerLocalId) {
    return Playlist(
      id: -1, // ID local será atribuído pelo banco de dados local
      name: name,
      description: description,
      createdBy: ownerLocalId,
      isPublic: isPublic,
      updatedAt: updatedAt,
      createdAt: createdAt,
      collaborators: collaborators
          .map((collaborator) => collaborator['id'] as String)
          .toList(),
      items: items,
      firebaseId: firebaseId,
    );
  }
}
