import '../../helpers/datetime_helper.dart';

class Playlist {
  final int id;
  final String name; 
  final String? description;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<int> cipherMapIds; // Changed from cipherIds to cipherMapIds
  final List<String> collaborators;

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.cipherMapIds = const [],
    this.collaborators = const [],
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdBy: json['created_by'] as String? ?? '',
      createdAt: DatetimeHelper.parseDateTime(json['created_at']),
      updatedAt: DatetimeHelper.parseDateTime(json['updated_at']),
      cipherMapIds: json['cipher_map_ids'] != null
        ? List<int>.from(json['cipher_map_ids'])
        : const[],
      collaborators: json['collaborators'] != null
        ? List<String>.from(json['collaborators'])
        : const[],
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
      'cipher_map_ids': cipherMapIds,
      'collaborators': collaborators,
    };
  }

  // Database-specific serialization (excludes relational data)
  Map<String, dynamic> toDatabaseJson() {
    final result = <String, dynamic>{
      'name': name,
      'description': description,
      'author_id': int.parse(createdBy), // Assuming createdBy is user ID as string
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
    
    // Only include id if it's not 0 (for updates)
    if (id != 0) {
      result['id'] = id;
    }
    
    return result;
  }

  Playlist copyWith({
   int? id,
   String? name,
   String? description,
   String? createdBy,
   DateTime? createdAt,
   DateTime? updatedAt,
   List<int>? cipherMapIds, 
   List<String>? collaborators,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cipherMapIds: cipherMapIds ?? this.cipherMapIds,
      collaborators: collaborators ?? this.collaborators,
    );
  }

  Playlist addCipherMapToPlaylist(int cipherMapId) => copyWith(
      cipherMapIds: [...cipherMapIds, cipherMapId],
      updatedAt: DateTime.now(),
    );
    
  Playlist removeCipherMapFromPlaylist(int cipherMapId) => copyWith(
    cipherMapIds: cipherMapIds.where((id) => id != cipherMapId).toList(),
    updatedAt: DateTime.now(),
  );
 
  Playlist reorderCipherMaps(List<int> newCipherMapIds) => copyWith(
    cipherMapIds: newCipherMapIds,
    updatedAt: DateTime.now(),
  );
}
