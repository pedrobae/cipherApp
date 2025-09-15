import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../helpers/datetime.dart';
import '../../utils/color.dart' as c;

class Cipher {
  final int? id;
  final String title;
  final String author;
  final String tempo;
  final String musicKey;
  final String language;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isLocal;
  final List<String> tags;
  final List<CipherVersion> maps;

  const Cipher({
    this.id,
    required this.title,
    required this.author,
    required this.tempo,
    this.tags = const [],
    required this.musicKey,
    required this.language,
    this.createdAt,
    this.updatedAt,
    required this.isLocal,
    this.maps = const [],
  });

  // From JSON constructor for database
  factory Cipher.fromJson(Map<String, dynamic> json) {
    return Cipher(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      tempo: json['tempo'] as String? ?? '',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const [],
      musicKey: json['music_key'] as String? ?? '',
      language: json['language'] as String? ?? 'por',
      createdAt: DatetimeHelper.parseDateTime(json['created_at']),
      updatedAt: DatetimeHelper.parseDateTime(json['updated_at']),
      isLocal: json['isLocal'] as bool? ?? true, // Default to true for local DB
      maps: json['maps'] != null
          ? (json['maps'] as List)
                .map((m) => CipherVersion.fromJson(m))
                .toList()
          : const [],
    );
  }

  // To JSON for database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'tempo': tempo,
      'music_key': musicKey,
      'language': language,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Cipher copyWith({
    int? id,
    String? title,
    String? author,
    String? tempo,
    List<String>? tags,
    String? musicKey,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLocal,
    List<CipherVersion>? maps,
  }) {
    return Cipher(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      tempo: tempo ?? this.tempo,
      tags: tags ?? this.tags,
      musicKey: musicKey ?? this.musicKey,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLocal: isLocal ?? this.isLocal,
      maps: maps ?? this.maps,
    );
  }
}

class CipherVersion {
  final int? id;
  final int cipherId;
  final String songStructure;
  final String? transposedKey;
  final String? versionName;
  final DateTime? createdAt;
  final Map<String, Section>? sections;

  const CipherVersion({
    this.id,
    required this.cipherId,
    required this.songStructure,
    this.transposedKey,
    this.versionName,
    this.createdAt,
    this.sections,
  });

  factory CipherVersion.fromJson(Map<String, dynamic> json) {
    Map<String, Section> versionContentMap = {};
    for (Map<String, dynamic> content in json['content']) {
      Section versionContent = Section.fromJson(content);
      versionContentMap[versionContent.contentCode] = versionContent;
    }

    return CipherVersion(
      id: json['id'] as int?,
      cipherId: json['cipher_id'] as int,
      songStructure: json['song_structure'] as String? ?? '',
      transposedKey: json['transposed_key'] as String?,
      versionName: json['version_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      sections: versionContentMap,
    );
  }

  // Factory for database row (without content - populated separately)
  factory CipherVersion.fromRow(Map<String, dynamic> row) {
    return CipherVersion(
      id: row['id'] as int?,
      cipherId: row['cipher_id'] as int,
      songStructure: row['song_structure'] as String? ?? '',
      transposedKey: row['transposed_key'] as String?,
      versionName: row['version_name'] as String?,
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'])
          : null,
      sections: null, // Will be populated separately by repository
    );
  }

  // To JSON for database (without content - sections handled separately)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cipher_id': cipherId,
      'song_structure': songStructure,
      'transposed_key': transposedKey,
      'version_name': versionName,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  List<Section> getContentAsStruct() {
    return (sections ?? {}).values.toList();
  }

  bool hasAllSections() {
    final requiredSections = songStructure.split(',').toSet();
    return requiredSections.every((section) => sections!.containsKey(section));
  }

  CipherVersion copyWith({
    int? id,
    int? cipherId,
    String? songStructure,
    String? transposedKey,
    String? versionName,
    DateTime? createdAt,
    Map<String, Section>? content,
  }) {
    return CipherVersion(
      id: id ?? this.id,
      cipherId: cipherId ?? this.cipherId,
      songStructure: songStructure ?? this.songStructure,
      transposedKey: transposedKey ?? this.transposedKey,
      versionName: versionName ?? this.versionName,
      createdAt: createdAt ?? this.createdAt,
      sections: content ?? sections,
    );
  }
}

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
