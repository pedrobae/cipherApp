import 'package:cipher_app/models/domain/cipher/cipher.dart';
import 'package:cipher_app/models/domain/cipher/version.dart';

/// DTO para metadados de cifra (usado para navegação, busca e listagem).
class CipherDto {
  final String? firebaseId; // ID na nuvem (Firebase)
  final String title;
  final String author;
  final String musicKey;
  final String tempo;
  final String language;
  final String searchTerm;
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
    required this.searchTerm,
    this.tags = const [],
    this.updatedAt,
    this.downloadCount,
  });

  factory CipherDto.fromMap(Map<String, dynamic> map) {
    return CipherDto(
      firebaseId: map['cipherId'] as String?,
      title: map['title'] as String? ?? '',
      author: map['author'] as String? ?? '',
      musicKey: map['musicKey'] as String? ?? '',
      tempo: map['tempo'] as String? ?? '',
      language: map['language'] as String? ?? '',
      searchTerm: map['searchTerm'] as String? ?? '',
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
      'id': firebaseId,
      'title': title,
      'author': author,
      'musicKey': musicKey,
      'tempo': tempo,
      'language': language,
      'searchTerm': '$title $author ${tags.join(' ')}'.toLowerCase(),
      'tags': tags.join(','),
      'updatedAt': updatedAt?.toIso8601String(),
      'downloadCount': downloadCount,
    };
  }

  Cipher toDomain(List<Version> versions) {
    return Cipher(
      id: null,
      title: title,
      author: author,
      musicKey: musicKey,
      language: language,
      tempo: tempo,
      tags: tags,
      isLocal: false,
      versions: versions,
    );
  }

  CipherDto copyWith({
    String? firebaseId,
    String? title,
    String? author,
    String? musicKey,
    String? tempo,
    String? language,
    String? searchTerm,
    List<String>? tags,
    DateTime? updatedAt,
    int? downloadCount,
  }) {
    return CipherDto(
      firebaseId: firebaseId ?? this.firebaseId,
      title: title ?? this.title,
      author: author ?? this.author,
      musicKey: musicKey ?? this.musicKey,
      tempo: tempo ?? this.tempo,
      language: language ?? this.language,
      tags: tags ?? this.tags,
      updatedAt: updatedAt ?? this.updatedAt,
      downloadCount: downloadCount ?? this.downloadCount,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }
}
