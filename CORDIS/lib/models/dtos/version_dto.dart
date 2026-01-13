import 'package:cordis/models/domain/cipher/section.dart';
import 'package:cordis/models/domain/cipher/version.dart';
import 'package:cordis/helpers/firestore_timestamp_helper.dart';

/// DTO para metadados de version (camada de separação entre a nuvem e o armazenamento local).
class VersionDto {
  final String? firebaseId; // ID na nuvem (Firebase)
  final String title;
  final String author;
  final String bpm;
  final String duration;
  final String language;
  final List<String> tags;
  final String versionName;
  final String originalKey;
  final String? transposedKey;
  final List<String> songStructure;
  final DateTime? updatedAt;
  final Map<String, Map<String, String>> sections;

  VersionDto({
    this.firebaseId,
    required this.versionName,
    required this.songStructure,
    this.updatedAt,
    required this.sections,
    required this.title,
    required this.author,
    required this.bpm,
    required this.duration,
    required this.language,
    this.tags = const [],
    required this.originalKey,
    this.transposedKey,
  });

  factory VersionDto.fromFirestore(Map<String, dynamic> map, String id) {
    return VersionDto(
      firebaseId: id,
      author: map['author'] as String,
      title: map['title'] as String,
      duration: map['duration'] as String? ?? '',
      bpm: map['bpm'] as String? ?? '',
      language: map['language'] as String,
      versionName: map['versionName'] as String,
      originalKey: map['originalKey'] as String,
      transposedKey: map['transposedKey'] as String?,
      tags: (map['tags'] as List<dynamic>).map((e) => e.toString()).toList(),
      songStructure: (map['songStructure'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      updatedAt: FirestoreTimestampHelper.toDateTime(map['updatedAt']),
      sections: (map['sections'] as Map<String, dynamic>).map(
        (sectionsCode, section) =>
            MapEntry(sectionsCode, Map<String, String>.from(section)),
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'author': author,
      'title': title,
      'duration': duration,
      'bpm': bpm,
      'language': language,
      'versionName': versionName,
      'originalKey': originalKey,
      'transposedKey': transposedKey,
      'tags': tags,
      'songStructure': songStructure,
      'updatedAt': FirestoreTimestampHelper.fromDateTime(updatedAt),
      'sections': sections,
    };
  }

  /// To JSON for caching (weekly public versions)
  Map<String, dynamic> toCache() {
    return {
      'firebaseId': firebaseId,
      'author': author,
      'title': title,
      'duration': duration,
      'bpm': bpm,
      'language': language,
      'versionName': versionName,
      'originalKey': originalKey,
      'transposedKey': transposedKey,
      'tags': tags,
      'songStructure': songStructure,
      'updatedAt': FirestoreTimestampHelper.fromDateTime(updatedAt),
      'sections': sections,
    };
  }

  Version toDomain({int? cipherId}) {
    return Version(
      firebaseId: firebaseId,
      versionName: versionName,
      transposedKey: transposedKey,
      songStructure: songStructure,
      createdAt: updatedAt ?? DateTime.now(),
      sections: sections.map(
        (sectionsCode, section) =>
            MapEntry(sectionsCode, Section.fromFirestore(section)),
      ),
      cipherId: cipherId ?? -1,
    );
  }

  VersionDto copyWith({
    String? firebaseId,
    String? title,
    String? author,
    String? duration,
    String? bpm,
    String? language,
    List<String>? tags,
    String? versionName,
    String? originalKey,
    String? transposedKey,
    List<String>? songStructure,
    DateTime? updatedAt,
    Map<String, Map<String, String>>? sections,
  }) {
    return VersionDto(
      firebaseId: firebaseId ?? this.firebaseId,
      title: title ?? this.title,
      author: author ?? this.author,
      duration: duration ?? this.duration,
      bpm: bpm ?? this.bpm,
      language: language ?? this.language,
      tags: tags ?? this.tags,
      versionName: versionName ?? this.versionName,
      originalKey: originalKey ?? this.originalKey,
      transposedKey: transposedKey ?? this.transposedKey,
      songStructure: songStructure ?? this.songStructure,
      updatedAt: updatedAt ?? this.updatedAt,
      sections: sections ?? this.sections,
    );
  }
}
