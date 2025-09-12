import 'package:sqflite/sqflite.dart';

Future<Map<String, int>> insertPlaylists(Transaction txn, Map<String, int> userIds, Map<String, int> mapIds) async {
  final now = DateTime.now().toIso8601String();
  final testUserId = userIds['testuser']!;

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

  // Additional playlist for Maria (vocalist)
  int mariaPlaylistId = await txn.insert('playlist', {
    'name': 'Ministério de Louvor',
    'description': 'Repertório especial para momentos de adoração',
    'author_id': userIds['maria']!,
    'is_public': 0,
    'created_at': now,
    'updated_at': now,
  });

  // Add cipher maps to worship playlist
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

  // Add cipher maps to evening playlist
  await txn.insert('playlist_cipher_map', {
    'cipher_map_id': mapIds['howgreat1'],
    'playlist_id': eveningPlaylistId,
    'includer_id': testUserId,
    'position': 0,
    'included_at': now,
  });

  // Add cipher maps to Maria's playlist
  await txn.insert('playlist_cipher_map', {
    'cipher_map_id': mapIds['amazing1'],
    'playlist_id': mariaPlaylistId,
    'includer_id': userIds['maria']!,
    'position': 0,
    'included_at': now,
  });

  return {
    'worship': worshipPlaylistId, 
    'evening': eveningPlaylistId,
    'maria_ministry': mariaPlaylistId,
  };
}

// For backward compatibility with old signature
Future<Map<String, int>> insertPlaylistsLegacy(Transaction txn, int testUserId, Map<String, int> mapIds) async {
  final userIds = {'testuser': testUserId};
  final playlists = await insertPlaylists(txn, userIds, mapIds);
  return {'worship': playlists['worship']!, 'evening': playlists['evening']!};
}
