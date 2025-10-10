import 'package:cipher_app/models/domain/cipher/section.dart';
import 'package:cipher_app/models/domain/cipher/version.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// DTO para metadados de version (camada de separação entre a nuvem e o armazenamento local).
class VersionDto {
  final String? firebaseId; // ID na nuvem (Firebase)
  final String versionName;
  final String? transposedKey;
  final String songStructure;
  final DateTime? createdAt;
  final Map<String, Map<String, dynamic>>? sections;

  VersionDto({
    this.firebaseId,
    required this.versionName,
    this.transposedKey,
    required this.songStructure,
    this.createdAt,
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
      createdAt: (map['createdAt'] as Timestamp).toDate(),
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
      'createdAt': createdAt?.toIso8601String(),
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
      createdAt: createdAt,
      sections: sections?.map(
        (sectionsCode, section) =>
            MapEntry(sectionsCode, Section.fromFirestore(section)),
      ),
      cipherId: 0,
    );
  }
}
