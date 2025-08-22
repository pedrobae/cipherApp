enum InfoType { news, announcement, event }

class InfoItem {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime publishedAt;
  final InfoType type;
  final String? link;
  final Map<String, dynamic>? highlight;
  final Map<String, dynamic>? metadata;

  const InfoItem({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.publishedAt,
    required this.type,
    this.highlight,
    this.link,
    this.metadata,
  });

  factory InfoItem.fromJson(Map<String, dynamic> json) {
    return InfoItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      type: InfoType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => InfoType.news,
      ),
      highlight: json['highlight'] as Map<String, dynamic>?,
      link: json['link'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'publishedAt': publishedAt.toIso8601String(),
    'type': type.name,
    'highlight': highlight,
    'link': link,
    'metadata': metadata,
  };
}
