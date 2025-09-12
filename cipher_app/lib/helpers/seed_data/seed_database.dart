import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'info.dart';
import 'users.dart';
import 'tags.dart';
import 'ciphers.dart';
import 'versions.dart';
import 'sections.dart';
import 'playlists.dart';
import 'collaborators.dart';

Future<void> seedDatabase(Database db) async {
  await db.transaction((txn) async {
    // Insert ciphers
    final cipherIds = await insertCiphers(txn);

    // Insert tags
    final tagIds = await insertTags(txn);

    // Link tags to ciphers
    await txn.insert('cipher_tags', {
      'cipher_id': cipherIds['amazing'],
      'tag_id': tagIds['classic'],
      'created_at': DateTime.now().toIso8601String(),
    });
    await txn.insert('cipher_tags', {
      'cipher_id': cipherIds['amazing'],
      'tag_id': tagIds['popular'],
      'created_at': DateTime.now().toIso8601String(),
    });
    await txn.insert('cipher_tags', {
      'cipher_id': cipherIds['howgreat'],
      'tag_id': tagIds['classic'],
      'created_at': DateTime.now().toIso8601String(),
    });

    // Insert cipher maps
    final mapIds = await insertCipherMaps(
      txn,
      cipherIds['amazing']!,
      cipherIds['howgreat']!,
    );

    // Insert map contents
    await insertMapContents(txn, mapIds);

    // Create users (including test user and band members)
    final userIds = await insertUsers(txn);

    // Create playlists with the new user structure
    final playlistIds = await insertPlaylists(txn, userIds, mapIds);

    // Create collaborator relationships between users and playlists
    await insertCollaborators(txn, userIds, playlistIds);

    // Seed info items after cipher data
    await seedInfoDatabase(db);
  });
}
