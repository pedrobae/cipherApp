/// Represents a content item in a playlist (cipher version or text section)
class PlaylistItem {
  final String type; // 'cipher_version' or 'text_section'
  final int? id;
  final String? firebaseId;
  final int? contentId;
  final String? firebaseContentId;
  int position;

  PlaylistItem({
    this.id,
    required this.type,
    this.firebaseId,
    this.contentId,
    required this.position,
    this.firebaseContentId,
  });

  // Content type constants
  static const String cipherVersionType = 'cipher_version';
  static const String textSectionType = 'text_section';

  factory PlaylistItem.fromJson(Map<String, dynamic> json) {
    return PlaylistItem(
      id: json['id'] as int,
      type: json['content_type'] as String,
      contentId: json['content_id'] as int,
      position: json['order_index'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content_type': type,
      'content_id': contentId,
      'order_index': position,
    };
  }

  // Helper constructors
  PlaylistItem.cipherVersion(int cipherVersionId, int order, int id)
    : this(
        id: id,
        type: cipherVersionType,
        contentId: cipherVersionId,
        position: order,
      );

  PlaylistItem.textSection(int textSectionId, int order, int id)
    : this(
        id: id,
        type: textSectionType,
        contentId: textSectionId,
        position: order,
      );

  // Type checking helpers
  bool get isCipherVersion => type == cipherVersionType;
  bool get isTextSection => type == textSectionType;

  PlaylistItem copyWith({String? type, int? contentId, int? order}) {
    return PlaylistItem(
      id: id,
      type: type ?? this.type,
      contentId: contentId ?? this.contentId,
      position: order ?? this.position,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaylistItem &&
        other.type == type &&
        other.contentId == contentId &&
        other.position == position;
  }

  @override
  int get hashCode => type.hashCode ^ contentId.hashCode ^ position.hashCode;

  @override
  String toString() {
    return 'PlaylistItem(type: $type, contentId: $contentId, order: $position)';
  }
}
