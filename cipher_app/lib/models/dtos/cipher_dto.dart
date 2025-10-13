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

  factory CipherDto.fromFirestore(Map<String, dynamic> map, String documentId) {
    return CipherDto(
      firebaseId: documentId,
      title: map['title'] as String? ?? '',
      author: map['author'] as String? ?? '',
      musicKey: map['musicKey'] as String? ?? '',
      tempo: map['tempo'] as String? ?? '',
      language: map['language'] as String? ?? '',
      tags: (map['tags'] is String)
          ? (map['tags'] as String)
                .split(',')
                .where((t) => t.isNotEmpty)
                .toList()
          : (map['tags'] as List?)?.cast<String>() ?? [],
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
      downloadCount: map['downloadCount'] as int?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'titleLower': title.toLowerCase(),
      'author': author,
      'authorLower': author.toLowerCase(),
      'musicKey': musicKey,
      'tempo': tempo,
      'language': language,
      'searchTokens': [
        ...title.toLowerCase().split(' '),
        ...author.toLowerCase().split(' '),
        ...tags.map((t) => t.toLowerCase()),
      ],
      'tags': tags,
      'downloadCount': downloadCount,
    };
  }

  Cipher toDomain(List<Version> versions) {
    return Cipher(
      id: null,
      firebaseId: firebaseId,
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
    );
  }
}
