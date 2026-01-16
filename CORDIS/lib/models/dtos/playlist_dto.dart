import 'package:cordis/models/domain/playlist/playlist.dart';
import 'package:cordis/models/domain/playlist/playlist_item.dart';
import 'package:cordis/models/dtos/version_dto.dart';
import 'package:cordis/helpers/firestore_timestamp_helper.dart';

class PlaylistDto {
  final String? firebaseId; // ID na nuvem (Firebase)
  final String name;
  final String description;
  final String ownerId; // Usuário que criou a playlist
  final bool isPublic;
  final DateTime updatedAt;
  final DateTime createdAt;
  final List<String> collaborators; // [userId1, userId2, ...]
  final String? shareCode;
  final List<String> itemOrder;
  final List<Map<String, String>> textSections;
  final List<VersionDto> versions;

  const PlaylistDto({
    this.firebaseId,
    required this.name,
    required this.description,
    required this.ownerId,
    this.isPublic = false,
    required this.updatedAt,
    required this.createdAt,
    this.collaborators = const [],
    this.shareCode,
    this.itemOrder = const [],
    this.textSections = const [],
    this.versions = const [],
  });

  factory PlaylistDto.fromFirestore(Map<String, dynamic> json) {
    return PlaylistDto(
      firebaseId: json['firebaseId'] as String?,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      ownerId: json['ownerId'] as String,
      updatedAt:
          FirestoreTimestampHelper.toDateTime(json['updatedAt']) ??
          DateTime.now(),
      createdAt:
          FirestoreTimestampHelper.toDateTime(json['createdAt']) ??
          DateTime.now(),
      collaborators: List<String>.from(
        json['collaborators'] as List<dynamic>? ?? [],
      ),
      shareCode: json['shareCode'] as String?,
      itemOrder:
          (json['itemOrder'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      textSections: json['textSections'] as List<Map<String, String>>,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'updatedAt': FirestoreTimestampHelper.fromDateTime(updatedAt),
      'createdAt': FirestoreTimestampHelper.fromDateTime(createdAt),
      'collaborators': collaborators,
      'shareCode': shareCode,
      'itemOrder': itemOrder,
      'textSections': textSections,
      'versions': versions.map((version) => version.toFirestore()).toList(),
    };
  }

  /// Method to convert PlaylistDto to Playlist domain model items must be inserted first
  Playlist toDomain(List<PlaylistItem> items, int ownerLocalId) {
    return Playlist(
      id: -1, // ID local será atribuído pelo banco de dados local
      name: name,
      description: description,
      createdBy: ownerLocalId,
      isPublic: isPublic,
      updatedAt: updatedAt,
      createdAt: createdAt,
      collaborators: collaborators,
      shareCode: shareCode,
      items: items,
      firebaseId: firebaseId,
    );
  }

  void addVersions(List<VersionDto> newVersions) {
    versions.addAll(newVersions);
  }

  void removeVersionByFirebaseId(String versionFirebaseId) {
    versions.removeWhere((v) => v.firebaseId == versionFirebaseId);
  }
}
