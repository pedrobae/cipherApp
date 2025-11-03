class TextSectionDto {
  final String? firebaseId;
  final String title;
  final String content;

  TextSectionDto({this.firebaseId, required this.title, required this.content});

  factory TextSectionDto.fromFirestore(Map<String, dynamic> json) {
    return TextSectionDto(
      firebaseId: json['id'] as String?,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'firebaseId': firebaseId, 'title': title, 'content': content};
  }
}
