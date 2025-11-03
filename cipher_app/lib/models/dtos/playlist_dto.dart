import 'package:cipher_app/models/domain/playlist/playlist.dart';
import 'package:cipher_app/models/domain/playlist/playlist_item.dart';
import 'package:cipher_app/models/dtos/cipher_dto.dart';
import 'package:cipher_app/models/dtos/version_dto.dart';
import 'package:cipher_app/models/dtos/text_section_dto.dart';
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
  final String shareCode;
  final List<String> itemOrder;
  final List<TextSectionDto> textSections;
  final List<VersionDto> versions;
  final List<CipherDto> ciphers;

  const PlaylistDto({
    this.firebaseId,
    required this.name,
    required this.description,
    required this.ownerId,
    this.isPublic = false,
    required this.updatedAt,
    required this.createdAt,
    this.collaborators = const [],
    required this.shareCode,
    this.itemOrder = const [],
    this.textSections = const [],
    this.versions = const [],
    this.ciphers = const [],
  });

  factory PlaylistDto.fromFirestore(Map<String, dynamic> json, String id) {
    return PlaylistDto(
      firebaseId: id,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      updatedAt:
          FirestoreTimestampHelper.toDateTime(json['updatedAt']) ??
          DateTime.now(),
      createdAt:
          FirestoreTimestampHelper.toDateTime(json['createdAt']) ??
          DateTime.now(),
      collaborators: List<Map<String, dynamic>>.from(
        json['collaborators'] ?? [],
      ),
      shareCode: json['shareCode'] as String,
      itemOrder: json['itemOrder'] as List<String>? ?? [],
      textSections: (json['textSections'] as List<Map<String, dynamic>>)
          .map((section) => TextSectionDto.fromFirestore(section))
          .toList(),
      versions: (json['versions'] as List<Map<String, dynamic>>)
          .map((version) => VersionDto.fromFirestore(version))
          .toList(),
      ciphers: (json['versions'] as List<Map<String, dynamic>>)
          .map((version) => CipherDto.fromFirestore(version))
          .toList(),
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
      'collaboratorIds': collaborators
          .map((collaborator) => collaborator['id'] as String)
          .toList(),
      'shareCode': shareCode,
      'itemOrder': itemOrder,
      'textSections': textSections
          .map((section) => section.toFirestore())
          .toList(),
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
      collaborators: collaborators
          .map((collaborator) => collaborator['id'] as String)
          .toList(),
      shareCode: shareCode,
      items: items,
      firebaseId: firebaseId,
    );
  }
}
