import 'package:cordis/utils/color.dart' as c;
import 'package:flutter/cupertino.dart';

class Section {
  final int? id;
  final int versionId;
  final String contentType;
  final String contentCode;
  String contentText;
  final Color contentColor;

  Section({
    this.id,
    required this.versionId,
    required this.contentType,
    required this.contentCode,
    required this.contentText,
    required this.contentColor,
  });

  factory Section.fromSqLite(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      versionId: json['version_id'],
      contentType: json['content_type'],
      contentCode: json['content_code'],
      contentText: json['content_text'],
      contentColor: c.colorFromHex(json['content_color']),
    );
  }

  factory Section.fromFirestore(Map<String, dynamic> map) {
    return Section(
      versionId: 0, // Will be set later
      contentType: map['contentType'] as String? ?? '',
      contentCode: map['contentCode'] as String? ?? '',
      contentText: map['contentText'] as String? ?? '',
      contentColor: c.colorFromHex(
        map['contentColor'] as String? ?? '#FFFFFFFF',
      ),
    );
  }

  Map<String, dynamic> toSqLite() {
    return {
      'content_type': contentType,
      'content_code': contentCode,
      'content_text': contentText,
      'content_color': c.colorToHex(contentColor),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'contentType': contentType,
      'contentCode': contentCode,
      'contentText': contentText,
      'contentColor': c.colorToHex(contentColor),
    };
  }

  Section copyWith({
    int? id,
    int? versionId,
    String? contentType,
    String? contentCode,
    String? contentText,
    Color? contentColor,
  }) {
    return Section(
      id: id ?? this.id,
      versionId: versionId ?? this.versionId,
      contentType: contentType ?? this.contentType,
      contentCode: contentCode ?? this.contentCode,
      contentText: contentText ?? this.contentText,
      contentColor: contentColor ?? this.contentColor,
    );
  }
}
