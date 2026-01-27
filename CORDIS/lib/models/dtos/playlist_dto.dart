import 'package:cordis/models/domain/playlist/playlist.dart';
import 'package:cordis/models/domain/playlist/playlist_item.dart';
import 'package:cordis/models/dtos/version_dto.dart';

class PlaylistDto {
  final String? firebaseId; // ID na nuvem (Firebase)
  final String name;
  final String ownerId; // Usuário que criou a playlist
  final List<String> itemOrder;
  final List<Map<String, String>> textSections;
  final List<VersionDto> versions;

  const PlaylistDto({
    this.firebaseId,
    required this.name,
    required this.ownerId,
    this.itemOrder = const [],
    this.textSections = const [],
    this.versions = const [],
  });

  Duration getTotalDuration() {
    return textSections.fold(
      Duration.zero,
      (a, b) =>
          a +
          (b['duration'] != null
              ? Duration(seconds: int.parse(b['duration']!))
              : Duration.zero),
    );
  }

  factory PlaylistDto.fromFirestore(Map<String, dynamic> json) {
    return PlaylistDto(
      firebaseId: json['firebaseId'] as String?,
      name: json['name'] as String,
      ownerId: json['ownerId'] as String,
      itemOrder:
          (json['itemOrder'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      textSections: json['textSections'] as List<Map<String, String>>,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'itemOrder': itemOrder, 'textSections': textSections};
  }

  /// Method to convert PlaylistDto to Playlist domain model items must be inserted first
  Playlist toDomain(List<PlaylistItem> items, int ownerLocalId) {
    return Playlist(
      id: -1, // ID local será atribuído pelo banco de dados local
      name: name,
      createdBy: ownerLocalId,
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
