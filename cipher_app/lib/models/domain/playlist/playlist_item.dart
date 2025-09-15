/// Represents a content item in a playlist (cipher version or text section)
class PlaylistItem {
  final String type; // 'cipher_version' or 'text_section'
  final int contentId;
  int order;

  PlaylistItem({
    required this.type,
    required this.contentId,
    required this.order,
  });

  // Content type constants
  static const String cipherVersionType = 'cipher_version';
  static const String textSectionType = 'text_section';

  factory PlaylistItem.fromJson(Map<String, dynamic> json) {
    return PlaylistItem(
      type: json['content_type'] as String,
      contentId: json['content_id'] as int,
      order: json['order_index'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content_type': type,
      'content_id': contentId,
      'order_index': order,
    };
  }

  // Helper constructors
  PlaylistItem.cipherVersion(int cipherVersionId, int order)
    : this(type: cipherVersionType, contentId: cipherVersionId, order: order);

  PlaylistItem.textSection(int textSectionId, int order)
    : this(type: textSectionType, contentId: textSectionId, order: order);

  // Type checking helpers
  bool get isCipherVersion => type == cipherVersionType;
  bool get isTextSection => type == textSectionType;

  PlaylistItem copyWith({String? type, int? contentId, int? order}) {
    return PlaylistItem(
      type: type ?? this.type,
      contentId: contentId ?? this.contentId,
      order: order ?? this.order,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaylistItem &&
        other.type == type &&
        other.contentId == contentId &&
        other.order == order;
  }

  @override
  int get hashCode => type.hashCode ^ contentId.hashCode ^ order.hashCode;

  @override
  String toString() {
    return 'PlaylistItem(type: $type, contentId: $contentId, order: $order)';
  }
}
