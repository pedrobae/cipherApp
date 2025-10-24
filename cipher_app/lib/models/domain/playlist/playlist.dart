// ignore_for_file: avoid_print

import 'package:cipher_app/models/dtos/playlist_dto.dart';
import 'package:cipher_app/models/dtos/playlist_item_dto.dart';

import '../../../helpers/datetime.dart';
import 'playlist_item.dart';

class Playlist {
  final int id;
  final String name;
  final String? firebaseId;
  final String? description;
  final int createdBy;
  final bool? isPublic;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String> collaborators;
  final List<PlaylistItem> items; // Unified content items

  const Playlist({
    required this.id,
    this.firebaseId,
    required this.name,
    this.description,
    required this.createdBy,
    required this.isPublic,
    this.createdAt,
    this.updatedAt,
    this.collaborators = const [],
    this.items = const [],
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdBy: json['created_by'] as int? ?? 0,
      createdAt: DatetimeHelper.parseDateTime(json['created_at']),
      updatedAt: DatetimeHelper.parseDateTime(json['updated_at']),
      isPublic: _parseBoolean(json['is_public']),
      collaborators: json['collaborators'] != null
          ? List<String>.from(json['collaborators'])
          : const [],
      items: json['items'] != null
          ? (json['items'] as List)
                .map((item) => PlaylistItem.fromJson(item))
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_public': isPublic,
      'collaborators': collaborators,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // Database-specific serialization (excludes relational data)
  Map<String, dynamic> toDatabaseJson() {
    final result = <String, dynamic>{
      'name': name,
      'description': description,
      'firebase_id': firebaseId,
      'author_id': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_public': (isPublic ?? false) ? 1 : 0,
    };

    // Only include id if it's not -1 (for updates)
    if (id != -1) {
      result['id'] = id;
    }

    return result;
  }

  PlaylistDto toDto(
    String ownerFirebaseId,
    List<Map<String, dynamic>> collaborators,
    List<PlaylistItemDto> items,
  ) {
    return PlaylistDto(
      firebaseId: firebaseId,
      name: name,
      description: description ?? '',
      ownerId: ownerFirebaseId,
      isPublic: isPublic ?? false,
      updatedAt: updatedAt ?? DateTime.now(),
      createdAt: createdAt ?? DateTime.now(),
      collaborators: collaborators,
      items: items,
    );
  }

  Playlist copyWith({
    int? id,
    String? name,
    String? description,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? collaborators,
    List<PlaylistItem>? items,
    bool? isPublic,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      collaborators: collaborators ?? this.collaborators,
      items: items ?? this.items,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  // Methods for unified content items
  Playlist addCipherVersionItem(int cipherVersionId) {
    final position = items.length;
    final newItem = PlaylistItem.cipherVersion(
      cipherVersionId,
      position,
      -1,
    ); // id -1 for new items
    return copyWith(items: [...items, newItem], updatedAt: DateTime.now());
  }

  Playlist addTextSectionItem(int textSectionId) {
    final position = items.length;
    final newItem = PlaylistItem.textSection(
      textSectionId,
      position,
      -1,
    ); // id -1 for new items
    return copyWith(items: [...items, newItem], updatedAt: DateTime.now());
  }

  Playlist removeItem(String type, int contentId) {
    final updatedItems = items
        .where((item) => !(item.type == type && item.contentId == contentId))
        .toList();

    // Reorder remaining items
    final reorderedItems = updatedItems
        .asMap()
        .entries
        .map((entry) => entry.value.copyWith(position: entry.key))
        .toList();

    return copyWith(items: reorderedItems, updatedAt: DateTime.now());
  }

  // Convenience getters for filtering items by type
  List<PlaylistItem> get cipherVersionItems =>
      items.where((item) => item.isCipherVersion).toList();

  List<PlaylistItem> get textSectionItems =>
      items.where((item) => item.isTextSection).toList();

  // Helper to get text section IDs from items
  List<int?> get textSectionIdsFromItems => items
      .where((item) => item.isTextSection)
      .map((item) => item.contentId)
      .toList();

  List<PlaylistItem> get orderedItems {
    final ordered = List<PlaylistItem>.from(items)
      ..sort((a, b) => a.position.compareTo(b.position));
    return ordered;
  }

  // Debug method for quick playlist inspection
  void debugPrint() {
    print('=== Playlist Debug ===');
    print('ID: $id | Name: $name');
    print('Items: ${items.length}');
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      print(
        '  [$i] ${item.type} - ID: ${item.contentId} (order: ${item.position})',
      );
    }
    print('======================');
  }

  // Helper method to parse boolean from database (handles both bool and int types)
  static bool _parseBoolean(dynamic value) {
    if (value is bool) {
      return value;
    } else if (value is int) {
      return value == 1;
    } else {
      return false;
    }
  }
}
