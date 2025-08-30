import 'package:sqflite/sqflite.dart';

Future<Map<String, int>> insertPlaylists(Transaction txn, int testUserId, Map<String, int> mapIds) async {
  final now = DateTime.now().toIso8601String();

  int worshipPlaylistId = await txn.insert('playlist', {
    'name': 'Culto Dominical',
    'description': 'Músicas para o culto de domingo',
    'author_id': testUserId,
    'is_public': 0,
    'created_at': now,
    'updated_at': now,
  });

  int eveningPlaylistId = await txn.insert('playlist', {
    'name': 'Culto da Noite',
    'description': 'Seleção especial para cultos noturnos',
    'author_id': testUserId,
    'is_public': 1,
    'created_at': now,
    'updated_at': now,
  });

  await txn.insert('playlist_cipher_map', {
    'cipher_map_id': mapIds['amazing1'],
    'playlist_id': worshipPlaylistId,
    'includer_id': testUserId,
    'position': 0,
    'included_at': now,
  });

  await txn.insert('playlist_cipher_map', {
    'cipher_map_id': mapIds['howgreat1'],
    'playlist_id': worshipPlaylistId,
    'includer_id': testUserId,
    'position': 1,
    'included_at': now,
  });

  await txn.insert('playlist_cipher_map', {
    'cipher_map_id': mapIds['howgreat1'],
    'playlist_id': eveningPlaylistId,
    'includer_id': testUserId,
    'position': 0,
    'included_at': now,
  });

  return {'worship': worshipPlaylistId, 'evening': eveningPlaylistId};
}
