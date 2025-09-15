import 'package:cipher_app/models/domain/version.dart';
import '../../helpers/datetime.dart';

class Cipher {
  final int? id;
  final String title;
  final String author;
  final String tempo;
  final String musicKey;
  final String language;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isLocal;
  final List<String> tags;
  final List<Version> maps;

  const Cipher({
    this.id,
    required this.title,
    required this.author,
    required this.tempo,
    this.tags = const [],
    required this.musicKey,
    required this.language,
    this.createdAt,
    this.updatedAt,
    required this.isLocal,
    this.maps = const [],
  });

  // From JSON constructor for database
  factory Cipher.fromJson(Map<String, dynamic> json) {
    return Cipher(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      tempo: json['tempo'] as String? ?? '',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const [],
      musicKey: json['music_key'] as String? ?? '',
      language: json['language'] as String? ?? 'por',
      createdAt: DatetimeHelper.parseDateTime(json['created_at']),
      updatedAt: DatetimeHelper.parseDateTime(json['updated_at']),
      isLocal: json['isLocal'] as bool? ?? true, // Default to true for local DB
      maps: json['maps'] != null
          ? (json['maps'] as List).map((m) => Version.fromJson(m)).toList()
          : const [],
    );
  }

  // To JSON for database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'tempo': tempo,
      'music_key': musicKey,
      'language': language,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Cipher copyWith({
    int? id,
    String? title,
    String? author,
    String? tempo,
    List<String>? tags,
    String? musicKey,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLocal,
    List<Version>? maps,
  }) {
    return Cipher(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      tempo: tempo ?? this.tempo,
      tags: tags ?? this.tags,
      musicKey: musicKey ?? this.musicKey,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLocal: isLocal ?? this.isLocal,
      maps: maps ?? this.maps,
    );
  }
}
