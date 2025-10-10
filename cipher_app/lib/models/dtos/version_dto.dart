import 'package:cipher_app/models/domain/cipher/section.dart';
import 'package:cipher_app/models/domain/cipher/version.dart';

/// DTO para metadados de version (camada de separação entre a nuvem e o armazenamento local).
class VersionDto {
  final String? firebaseId; // ID na nuvem (Firebase)
  final String versionName;
  final String? transposedKey;
  final String songStructure;
  final DateTime? updatedAt;
  final Map<String, Map<String, dynamic>>? sections;

  VersionDto({
    this.firebaseId,
    required this.versionName,
    this.transposedKey,
    required this.songStructure,
    this.updatedAt,
    this.sections,
  });

  factory VersionDto.fromFirestore(Map<String, dynamic> map) {
    return VersionDto(
      firebaseId: map['versionId'] as String? ?? '',
      versionName: map['versionName'] as String? ?? '',
      transposedKey: map['transposedKey'] as String? ?? '',
      songStructure:
          (map['songStructure'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .join(',') ??
          '',
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
      sections: (map['sections'] as Map<String, dynamic>).map(
        (sectionCode, section) => MapEntry(sectionCode, section),
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firebaseId': firebaseId,
      'versionName': versionName,
      'transposedKey': transposedKey,
      'songStructure': songStructure,
      'updatedAt': updatedAt?.toIso8601String(),
      'sections': sections?.map(
        (sectionCode, section) => MapEntry(sectionCode, {
          'contentType': section['contentType'],
          'contentText': section['contentText'],
          'contentCode': section['contentCode'],
          'contentColor': section['contentColor'],
        }),
      ),
    };
  }

  Version toDomain() {
    return Version(
      versionName: versionName,
      transposedKey: transposedKey,
      songStructure: songStructure.split(',').map((s) => s.trim()).toList(),
      createdAt: updatedAt,
      sections: sections?.map(
        (sectionsCode, section) =>
            MapEntry(sectionsCode, Section.fromFirestore(section)),
      ),
      cipherId: 0,
    );
  }
}
