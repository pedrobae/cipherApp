import 'package:cipher_app/utils/color.dart' as c;
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

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      versionId: json['version_id'],
      contentType: json['content_type'],
      contentCode: json['content_code'],
      contentText: json['content_text'],
      contentColor: c.colorFromHex(json['content_color']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version_id': versionId,
      'content_type': contentType,
      'content_code': contentCode,
      'content_text': contentText,
      'color': c.colorToHex(contentColor),
    };
  }
}
