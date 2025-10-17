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

// TODO: SEED DATA UPDATE - Add firebase_id values when implementing cloud sync
// When updating schema with firebase_id columns, update these files:
// 1. users.dart → Add firebase_id field to insertUsers()
// 2. playlists.dart → Add firebase_id field to insertPlaylists()
// 3. versions.dart → Add firebase_id and firebase_cipher_id fields
// 4. Test data should use realistic Firebase ID format: "abc123xyz" (28 chars)
// 5. Ensure firebase_id values are unique across seed data

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

    // Insert versions (previously cipher maps)
    final versionIds = await insertVersions(
      txn,
      cipherIds['amazing']!,
      cipherIds['howgreat']!,
    );

    // Insert sections (previously map contents)
    await insertSections(txn, versionIds);

    // Create users (including test user and band members)
    final userIds = await insertUsers(txn);

    // Create playlists with the new user structure
    final playlistIds = await insertPlaylists(txn, userIds, versionIds);

    // Create collaborator relationships between users and playlists
    await insertCollaborators(txn, userIds, playlistIds);

    // Seed info items after cipher data
    await seedInfoDatabase(db);
  });
}
