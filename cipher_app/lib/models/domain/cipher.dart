class Cipher {
  final int id;
  final String title;
  final String author;
  final String tempo;
  final List<String> tags;
  final String key;
  final String language;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isLocal;
  final Map<String, String> musicStruct;

  const Cipher({
    required this.id,
    required this.title,
    required this.author,
    required this.tempo,
    this.tags = const [],
    required this.key,
    required this.language,
    required this.createdAt,
    required this.updatedAt,
    required this.isLocal,
    required this.musicStruct,
  });

  // From JSON constructor for Firestore
  factory Cipher.fromJson(Map<String, dynamic> json) {
    return Cipher(
      id: json['id'] as int,
      title: json['title'] as String,
      author: json['author'] as String,
      tempo: json['tempo'] as String,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const [],
      key: json['key'] as String,
      language: json['language'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isLocal: json['isLocal'] as bool,
      musicStruct: Map<String, String>.from(json['musicStruct']),
    );
  }

  // To JSON method for Firestore
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'tempo': tempo,
    'tags': tags,
    'key': key,
    'language': language,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isLocal': isLocal,
    'musicStruct': musicStruct,
  };
}
