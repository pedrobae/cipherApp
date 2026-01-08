import 'dart:convert';

enum InfoType { news, announcement, event }

class InfoItem {
  final int id;
  final String? firebaseId;
  final String title;
  final String description;
  final String? sourceUrl;
  final InfoType type;
  final int priority;
  final DateTime publishedAt;
  final DateTime? expiresAt;
  final DateTime fetchedAt;
  final bool isDismissible;
  final String? link;
  final Map<String, dynamic>? content;

  const InfoItem({
    required this.id,
    this.firebaseId,
    required this.title,
    required this.description,
    this.sourceUrl,
    required this.type,
    required this.priority,
    required this.publishedAt,
    this.expiresAt,
    required this.fetchedAt,
    required this.isDismissible,
    this.link,
    this.content,
  });

  factory InfoItem.fromJson(Map<String, dynamic> json) {
    return InfoItem(
      id: json['id'] as int,
      firebaseId: json['firebase_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      sourceUrl: json['source_url'] as String?,
      priority: json['priority'] as int,
      publishedAt: DateTime.parse(json['published_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      fetchedAt: DateTime.parse(json['fetched_at'] as String),
      type: InfoType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => InfoType.news,
      ),
      isDismissible: (json['is_dismissible'] as int) == 1,
      link: json['link'] as String?,
      content: json['content'] != null
          ? Map<String, dynamic>.from(jsonDecode(json['content'] as String))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firebase_id': firebaseId,
    'title': title,
    'description': description,
    'source_url': sourceUrl,
    'type': type.name,
    'priority': priority,
    'published_at': publishedAt.toIso8601String(),
    'expires_at': expiresAt?.toIso8601String(),
    'fetched_at': fetchedAt.toIso8601String(),
    'is_dismissible': isDismissible,
    'link': link,
  };
}
