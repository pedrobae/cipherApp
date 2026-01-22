import 'package:cordis/helpers/codes.dart';

class FlowItem {
  final int? id;
  final String firebaseId;
  final int playlistId;
  final String title;
  String contentText;
  final Duration duration;
  final int position;

  FlowItem({
    this.id,
    required this.firebaseId,
    required this.playlistId,
    required this.title,
    required this.contentText,
    required this.duration,
    required this.position,
  });

  factory FlowItem.fromSqlite({
    required int playlistId,
    required String title,
    required String contentText,
    required int position,
  }) {
    return FlowItem(
      firebaseId: generateFirebaseId(),
      playlistId: playlistId,
      duration: Duration(),
      title: title,
      contentText: contentText,
      position: position,
    );
  }

  factory FlowItem.fromFirestore(Map<String, dynamic> json) {
    return FlowItem(
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

  Map<String, dynamic> toSQLite(FlowItem flowItem) {
    return {
      'id': id,
      'firebase_id': firebaseId,
      'playlist_id': playlistId,
      'title': title,
      'content': contentText,
      'position': position,
      'duration': duration.inSeconds,
    };
  }

  Map<String, String> toFirestore() {
    return {'title': title, 'content': contentText, 'id': firebaseId};
  }
}
