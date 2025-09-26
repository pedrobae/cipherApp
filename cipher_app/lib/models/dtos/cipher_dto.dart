import 'package:cipher_app/models/domain/cipher/cipher.dart';

/// DTO para metadados de cifra (usado para navegação, busca e listagem).
class CipherDto {
  final String? firebaseId; // ID na nuvem (Firebase)
  final String title;
  final String author;
  final String musicKey;
  final String tempo;
  final String language;
  final List<String> tags;
  final DateTime? updatedAt;
  final int? downloadCount;

  CipherDto({
    this.firebaseId,
    required this.title,
    required this.author,
    required this.musicKey,
    required this.tempo,
    required this.language,
    this.tags = const [],
    this.updatedAt,
    this.downloadCount,
  });

  factory CipherDto.fromMap(Map<String, dynamic> map) {
    return CipherDto(
      firebaseId: map['firebase_id'] as String?,
      title: map['title'] as String? ?? '',
      author: map['author'] as String? ?? '',
      musicKey: map['music_key'] as String? ?? '',
      tempo: map['tempo'] as String? ?? '',
      language: map['language'] as String? ?? '',
      tags: (map['tags'] is String)
          ? (map['tags'] as String)
                .split(',')
                .where((t) => t.isNotEmpty)
                .toList()
          : (map['tags'] as List?)?.cast<String>() ?? [],
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
      downloadCount: map['download_count'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firebase_id': firebaseId,
      'title': title,
      'author': author,
      'music_key': musicKey,
      'tempo': tempo,
      'language': language,
      'tags': tags.join(','),
      'updated_at': updatedAt?.toIso8601String(),
      'download_count': downloadCount,
    };
  }

  Cipher toDomain() {
    return Cipher(
      id: null,
      title: title,
      author: author,
      musicKey: musicKey,
      language: language,
      tempo: tempo,
      tags: tags,
      isLocal: false,
    );
  }
}
