import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'info.dart';
import 'users.dart';
import 'tags.dart';
import 'ciphers.dart';
import 'cipher_maps.dart';
import 'map_contents.dart';
import 'playlists.dart';

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
    final mapIds = await insertCipherMaps(txn, cipherIds['amazing']!, cipherIds['howgreat']!);

    // Insert map contents
    await insertMapContents(txn, mapIds);

    // Seed info items after cipher data
    await seedInfoDatabase(db);

    // Create test user and playlists
    final testUserId = await insertTestUser(txn);
    await insertPlaylists(txn, testUserId, mapIds);
  });
}
