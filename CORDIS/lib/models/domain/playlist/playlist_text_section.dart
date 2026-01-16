import 'package:cordis/helpers/codes.dart';

class TextSection {
  final int? id;
  final String firebaseId;
  final int playlistId;
  final String title;
  String contentText;
  final Duration duration;
  final int position;

  TextSection({
    this.id,
    required this.firebaseId,
    required this.playlistId,
    required this.title,
    required this.contentText,
    required this.duration,
    required this.position,
  });

  factory TextSection.fromSqlite({
    required int playlistId,
    required String title,
    required String contentText,
    required int position,
  }) {
    return TextSection(
      firebaseId: generateFirebaseId(),
      playlistId: playlistId,
      duration: Duration(),
      title: title,
      contentText: contentText,
      position: position,
    );
  }

  factory TextSection.fromFirestore(Map<String, dynamic> json) {
    return TextSection(
      id: json['id'],
      playlistId: json['playlist_id'],
      firebaseId: json['firebase_id'] ?? generateFirebaseId(),
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'])
          : Duration.zero,
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

  Map<String, String> toFirestore() {
    return {'title': title, 'content': contentText, 'id': firebaseId};
  }
}
