import '../../helpers/datetime_helper.dart';

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
  final List<CipherMap> maps;

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
          ? (json['maps'] as List).map((m) => CipherMap.fromJson(m)).toList()
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

  Map<String, String> get musicStruct {
    if (maps.isEmpty) return {};
    return maps.first.getContentAsStruct();
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
    List<CipherMap>? maps,
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

class CipherMap {
  final int? id;
  final int cipherId; // Added: missing field
  final String songStructure;
  final String? transposedKey;
  final String? versionName;
  final DateTime? createdAt;
  final List<MapContent> content;

  const CipherMap({
    this.id,
    required this.cipherId, // Added: required field
    required this.songStructure,
    this.transposedKey,
    this.versionName,
    this.createdAt,
    this.content = const [],
  });

  factory CipherMap.fromJson(Map<String, dynamic> json) {
    return CipherMap(
      id: json['id'] as int?,
      cipherId: json['cipher_id'] as int, // Added: from database
      songStructure: json['song_structure'] as String? ?? '', // Fixed: use correct column name
      transposedKey: json['transposed_key'] as String?,
      versionName: json['version_name'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      content: json['content'] != null
          ? (json['content'] as List)
                .map((c) => MapContent.fromJson(c))
                .toList()
          : const [],
    );
  }

  // To JSON for database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cipher_id': cipherId,
      'song_structure': songStructure,
      'transposed_key': transposedKey,
      'version_name': versionName,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Map<String, String> getContentAsStruct() {
    Map<String, String> struct = {};
    for (var content in this.content) {
      struct[content.contentType] = content.contentText;
    }
    return struct;
  }

  CipherMap copyWith({
    int? id,
    int? cipherId,
    String? songStructure,
    String? transposedKey,
    String? versionName,
    DateTime? createdAt,
    List<MapContent>? content,
  }) {
    return CipherMap(
      id: id ?? this.id,
      cipherId: cipherId ?? this.cipherId,
      songStructure: songStructure ?? this.songStructure,
      transposedKey: transposedKey ?? this.transposedKey,
      versionName: versionName ?? this.versionName,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
    );
  }
}

class MapContent {
  final int? id; // Added: missing field
  final int mapId; // Added: missing field
  final String contentType;
  final String contentText;

  const MapContent({
    this.id, // Added: optional for new content
    required this.mapId, // Added: required field
    required this.contentType,
    required this.contentText,
  });

  factory MapContent.fromJson(Map<String, dynamic> json) {
    return MapContent(
      id: json['id'] as int?, // Added: from database
      mapId: json['map_id'] as int, // Added: from database
      contentType: json['content_type'] as String,
      contentText: json['content_text'] as String,
    );
  }

  // To JSON for database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'map_id': mapId,
      'content_type': contentType,
      'content_text': contentText,
    };
  }

  MapContent copyWith({
    int? id,
    int? mapId,
    String? contentType,
    String? contentText,
  }) {
    return MapContent(
      id: id ?? this.id,
      mapId: mapId ?? this.mapId,
      contentType: contentType ?? this.contentType,
      contentText: contentText ?? this.contentText,
    );
  }
}
