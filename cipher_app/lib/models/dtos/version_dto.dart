import 'package:cipher_app/models/domain/cipher/section.dart';
import 'package:cipher_app/models/domain/cipher/version.dart';
import 'package:cipher_app/helpers/firestore_timestamp_helper.dart';

/// DTO para metadados de version (camada de separação entre a nuvem e o armazenamento local).
class VersionDto {
  final String? firebaseId; // ID na nuvem (Firebase)
  final String? firebaseCipherId; // ID do cipher na nuvem (Firebase)
  final String versionName;
  final String? transposedKey;
  final String songStructure;
  final DateTime? updatedAt;
  final Map<String, Map<String, dynamic>>? sections;

  VersionDto({
    this.firebaseId,
    this.firebaseCipherId,
    required this.versionName,
    this.transposedKey,
    required this.songStructure,
    this.updatedAt,
    this.sections,
  });

  factory VersionDto.fromFirestore(
    Map<String, dynamic> map, {
    String? id,
    String? cipherId,
  }) {
    return VersionDto(
      firebaseId: id ?? map['id'] as String? ?? '',
      firebaseCipherId: cipherId ?? map['cipherId'] as String? ?? '',
      versionName: map['versionName'] as String? ?? '',
      transposedKey: map['transposedKey'] as String? ?? '',
      songStructure:
          (map['songStructure'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .join(',') ??
          '',
      updatedAt: FirestoreTimestampHelper.toDateTime(map['updatedAt']),
      sections: (map['sections'] as Map<String, dynamic>).map(
        (sectionCode, section) => MapEntry(sectionCode, section),
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'versionName': versionName,
      'transposedKey': transposedKey,
      'songStructure': songStructure.split(',').map((s) => s.trim()).toList(),
      'updatedAt': FirestoreTimestampHelper.fromDateTime(updatedAt),
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

  Version toDomain({int? cipherId}) {
    return Version(
      firebaseId: firebaseId,
      firebaseCipherId: firebaseCipherId,
      versionName: versionName,
      transposedKey: transposedKey,
      songStructure: songStructure.split(',').map((s) => s.trim()).toList(),
      createdAt: updatedAt,
      sections: sections?.map(
        (sectionsCode, section) =>
            MapEntry(sectionsCode, Section.fromFirestore(section)),
      ),
      cipherId: cipherId ?? 0,
    );
  }
}
