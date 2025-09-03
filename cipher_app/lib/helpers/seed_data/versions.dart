import 'package:sqflite/sqflite.dart';

Future<Map<String, int>> insertCipherMaps(Transaction txn, int hymn1Id, int hymn2Id) async {
  final now = DateTime.now().toIso8601String();

  int amazingGraceMap1Id = await txn.insert('cipher_map', {
    'cipher_id': hymn1Id,
    'song_structure': 'V1,V2,V3,V4',
    'transposed_key': null,
    'version_name': 'Original',
    'created_at': now,
  });

  int amazingGraceMap2Id = await txn.insert('cipher_map', {
    'cipher_id': hymn1Id,
    'song_structure': 'V1,V3,V4',
    'transposed_key': 'D',
    'version_name': 'Short Version (Key of D)',
    'created_at': now,
  });

  int howGreatMap1Id = await txn.insert('cipher_map', {
    'cipher_id': hymn2Id,
    'song_structure': 'V1,C,V2,C,V3,C,V4,C',
    'transposed_key': null,
    'version_name': 'Original',
    'created_at': now,
  });

  return {
    'amazing1': amazingGraceMap1Id,
    'amazing2': amazingGraceMap2Id,
    'howgreat1': howGreatMap1Id,
  };
}
