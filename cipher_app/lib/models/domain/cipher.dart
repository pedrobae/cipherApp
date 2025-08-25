class Cipher {
  final int? id;
  final String title;
  final String author;
  final String tempo;
  final List<String> tags;
  final String musicKey;
  final String language;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isLocal;
  final List<CipherMap> maps; // Changed from musicStruct

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

  // From JSON constructor for Firestore
  factory Cipher.fromJson(Map<String, dynamic> json) {
    return Cipher(
      id: json['id'] as int,
      title: json['title'] as String,
      author: json['author'] as String,
      tempo: json['tempo'] as String,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const [],
      musicKey: json['music_key'] as String,
      language: json['language'] as String,
      createdAt: DateTime.parse(json['created_at'] as String), // Fixed
      updatedAt: DateTime.parse(json['updated_at'] as String), // Fixed
      isLocal: true, // Default for local data
      maps: json['maps'] != null
          ? (json['maps'] as List).map((m) => CipherMap.fromJson(m)).toList()
          : const [],
    );
  }

  // Backward compatibility - get musicStruct from first map
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
  final int id;
  final String mapOrder;
  final String? transposedKey;
  final String? versionName;
  final List<MapContent> content;

  const CipherMap({
    required this.id,
    required this.mapOrder,
    this.transposedKey,
    this.versionName,
    this.content = const [],
  });

  factory CipherMap.fromJson(Map<String, dynamic> json) {
    return CipherMap(
      id: json['id'] as int,
      mapOrder: json['map_order'] as String,
      transposedKey: json['transposed_key'] as String?,
      versionName: json['version_name'] as String?,
      content: json['content'] != null
          ? (json['content'] as List)
                .map((c) => MapContent.fromJson(c))
                .toList()
          : const [],
    );
  }

  Map<String, String> getContentAsStruct() {
    Map<String, String> struct = {};
    for (var content in this.content) {
      struct[content.contentType] = content.contentText;
    }
    return struct;
  }
}

class MapContent {
  final String contentType;
  final String contentText;

  const MapContent({required this.contentType, required this.contentText});

  factory MapContent.fromJson(Map<String, dynamic> json) {
    return MapContent(
      contentType: json['content_type'] as String,
      contentText: json['content_text'] as String,
    );
  }
}
