import '../../helpers/datetime_helper.dart';

class Playlist {
  final int id;
  final String name; 
  final String? description;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<int> cipherIds; 
  final List<String> collaborators;

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.cipherIds = const [],
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
      cipherIds: json['cipher_ids'] != null
        ? List<int>.from(json['cipher_ids'])
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
      'cipher_ids': cipherIds,
      'collaborators': collaborators,
    };
  }

  // Database-specific serialization (excludes relational data)
  Map<String, dynamic> toDatabaseJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'author_id': int.parse(createdBy), // Assuming createdBy is user ID as string
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Playlist copyWith({
   int? id,
   String? name,
   String? description,
   String? createdBy,
   DateTime? createdAt,
   DateTime? updatedAt,
   List<int>? cipherIds, 
   List<String>? collaborators,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cipherIds: cipherIds ?? this.cipherIds,
      collaborators: collaborators ?? this.collaborators,
    );
  }

  Playlist addCipherToPlaylist(int cipherId) => copyWith(
      cipherIds: [...cipherIds, cipherId],
      updatedAt: DateTime.now(),
    );
    
  Playlist removeCipherFromPlaylist(int cipherId) => copyWith(
    cipherIds: cipherIds.where((id) => id != cipherId).toList(),
    updatedAt: DateTime.now(),
  );
 

  Playlist reorderCiphers (List<int> newCipherIds) => copyWith(
    cipherIds: newCipherIds,
    updatedAt: DateTime.now(),
  );
}