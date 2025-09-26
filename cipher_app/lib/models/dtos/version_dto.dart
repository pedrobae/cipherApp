import 'package:cipher_app/models/domain/cipher/section.dart';
import 'package:cipher_app/models/domain/cipher/version.dart';

/// DTO para metadados de version (camada de separação entre a nuvem e o armazenamento local).
class VersionDto {
  final String? firebaseId; // ID na nuvem (Firebase)
  final String versionName;
  final String? transposedKey;
  final String songStructure;
  final DateTime? createdAt;
  final Map<String, Section>? sections;

  VersionDto({
    this.firebaseId,
    required this.versionName,
    this.transposedKey,
    required this.songStructure,
    this.createdAt,
    this.sections,
  });

  factory VersionDto.fromMap(Map<String, dynamic> map) {
    return VersionDto(
      firebaseId: map['firebase_id'] as String?,
      versionName: map['version_name'] as String? ?? '',
      transposedKey: map['transposed_key'] as String? ?? '',
      songStructure: map['song_structure'] as String? ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      sections: (map['sections'] as Map<String, Map<String, String>>).map(
        (sectionCode, section) =>
            MapEntry(sectionCode, Section.fromJson(section)),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firebase_id': firebaseId,
      'version_name': versionName,
      'transposed_key': transposedKey,
      'song_structure': songStructure,
      'created_at': createdAt?.toIso8601String(),
      'sections': sections?.map(
        (sectionCode, section) => MapEntry(sectionCode, {
          'contentType': section.contentType,
          'contentText': section.contentText,
          'contentCode': section.contentCode,
          'contentColor': section.contentColor,
        }),
      ),
    };
  }

  Version toDomain(int cipherId) {
    return Version(
      id: null,
      versionName: versionName,
      transposedKey: transposedKey,
      songStructure: songStructure.split(',').map((s) => s.trim()).toList(),
      createdAt: createdAt,
      sections: sections,
      cipherId: cipherId,
    );
  }
}
