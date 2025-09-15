class TextSection {
  final int? id;
  final int playlistId;
  final String title;
  String contentText;
  final int position;
  final int includerId;

  TextSection({
    this.id,
    required this.playlistId,
    required this.title,
    required this.contentText,
    required this.position,
    required this.includerId,
  });

  factory TextSection.fromJson(Map<String, dynamic> json) {
    return TextSection(
      id: json['id'],
      playlistId: json['playlist_id'],
      title: json['title'],
      contentText: json['content'],
      position: json['position'] ?? 0,
      includerId: json['added_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playlist_id': playlistId,
      'title': title,
      'content': contentText,
      'position': position,
      'added_by': includerId,
    };
  }
}
