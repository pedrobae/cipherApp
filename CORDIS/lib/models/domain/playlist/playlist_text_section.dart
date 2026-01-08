import 'package:cordis/models/dtos/text_section_dto.dart';

class TextSection {
  final int? id;
  final String? firebaseId;
  final int playlistId;
  final String title;
  String contentText;
  final int position;

  TextSection({
    this.id,
    this.firebaseId,
    required this.playlistId,
    required this.title,
    required this.contentText,
    required this.position,
  });

  factory TextSection.fromJson(Map<String, dynamic> json) {
    return TextSection(
      id: json['id'],
      playlistId: json['playlist_id'],
      firebaseId: json['firebase_id'],
      title: json['title'],
      contentText: json['content'],
      position: json['position'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_id': firebaseId,
      'playlist_id': playlistId,
      'title': title,
      'content': contentText,
      'position': position,
    };
  }

  TextSectionDto toDto() {
    return TextSectionDto(
      firebaseId: firebaseId,
      title: title,
      content: contentText,
    );
  }
}
