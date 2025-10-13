import 'package:cipher_app/models/domain/cipher/section.dart';
import 'package:cipher_app/models/dtos/version_dto.dart';

class Version {
  final int? id;
  final String? firebaseId;
  final int cipherId;
  final String versionName;
  final String? transposedKey;
  final List<String> songStructure; // Changed from String to List<String>
  final DateTime? createdAt;
  final Map<String, Section>? sections;

  const Version({
    this.id,
    this.firebaseId,
    required this.cipherId,
    this.versionName = 'Original',
    this.transposedKey,
    this.songStructure = const [],
    this.createdAt,
    this.sections,
  });

  factory Version.fromSqLite(Map<String, dynamic> json) {
    Map<String, Section> versionContentMap = {};
    for (Map<String, dynamic> content in json['content']) {
      Section versionContent = Section.fromSqLite(content);
      versionContentMap[versionContent.contentCode] = versionContent;
    }

    return Version(
      id: json['id'] as int?,
      firebaseId: json['firebase_id'] as String?,
      cipherId: json['cipher_id'] as int,
      songStructure: json['song_structure'] as List<String>,
      transposedKey: json['transposed_key'] as String?,
      versionName: json['version_name'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      sections: versionContentMap,
    );
  }

  // Factory for database row (without content - populated separately)
  factory Version.fromSqLiteNoSections(Map<String, dynamic> row) {
    List<String> songStructure = [];
    final structureString = row['song_structure'] as String?;
    if (structureString != null && structureString.isNotEmpty) {
      songStructure = structureString
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return Version(
      id: row['id'] as int?,
      firebaseId: row['firebase_id'] as String?,
      cipherId: row['cipher_id'] as int,
      songStructure: songStructure,
      transposedKey: row['transposed_key'] as String?,
      versionName: row['version_name'] as String,
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'])
          : null,
      sections: null, // Will be populated separately by repository
    );
  }

  // To JSON for database (without content - sections handled separately)
  Map<String, dynamic> toSqLite() {
    return {
      'id': id,
      'firebase_id': firebaseId,
      'cipher_id': cipherId,
      'song_structure': songStructure.join(','),
      'transposed_key': transposedKey,
      'version_name': versionName,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  List<Section> getContentAsStruct() {
    return (sections ?? {}).values.toList();
  }

  VersionDto toDto() {
    return VersionDto(
      firebaseId: firebaseId,
      versionName: versionName,
      transposedKey: transposedKey,
      songStructure: songStructure.join(','),
      sections: sections?.map(
        (sectionCode, section) => MapEntry(sectionCode, section.toFirestore()),
      ),
    );
  }

  bool get hasAllSections {
    final requiredSections = songStructure.toSet();
    return requiredSections.every((section) => sections!.containsKey(section));
  }

  List<String> get uniqueSections => songStructure.toSet().toList();
  bool get isEmpty => songStructure.isEmpty;
  int get sectionCount => songStructure.length;

  bool containsSection(String sectionCode) =>
      songStructure.contains(sectionCode);

  Version copyWith({
    int? id,
    String? firebaseId,
    int? cipherId,
    List<String>? songStructure,
    String? transposedKey,
    String? versionName,
    DateTime? createdAt,
    Map<String, Section>? content,
  }) {
    return Version(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      cipherId: cipherId ?? this.cipherId,
      songStructure: songStructure ?? this.songStructure,
      transposedKey: transposedKey ?? this.transposedKey,
      versionName: versionName ?? this.versionName,
      createdAt: createdAt ?? this.createdAt,
      sections: content ?? sections,
    );
  }

  // Factory for creating empty version
  factory Version.empty({int? cipherId}) {
    return Version(
      cipherId: cipherId ?? -1,
      versionName: 'Versão 1',
      songStructure: [],
      transposedKey: '',
      sections: {},
    );
  }

  // Check if version is new (no ID)
  bool get isNew => id == -1;
}
