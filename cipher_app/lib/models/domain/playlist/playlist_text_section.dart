import 'package:cipher_app/models/dtos/playlist_item_dto.dart';

class TextSection {
  final int? id;
  final String? firebaseId;
  final int playlistId;
  final String title;
  String contentText;
  final int position;
  final int? includerId;

  TextSection({
    this.id,
    this.firebaseId,
    required this.playlistId,
    required this.title,
    required this.contentText,
    required this.position,
    this.includerId,
  });

  factory TextSection.fromJson(Map<String, dynamic> json) {
    return TextSection(
      id: json['id'],
      playlistId: json['playlist_id'],
      firebaseId: json['firebase_id'],
      title: json['title'],
      contentText: json['content'],
      position: json['position'] ?? 0,
      includerId: json['added_by'],
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
      'added_by': includerId,
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
