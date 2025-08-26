import 'dart:async';
import 'package:sqflite/sqflite.dart';

Future<void> seedDatabase(Database db) async {
  await db.transaction((txn) async {
    // Insert initial ciphers
    int hymn1Id = await txn.insert('cipher', {
      'title': 'Amazing Grace',
      'author': 'John Newton',
      'tempo': 'Slow',
      'music_key': 'G',
      'language': 'en',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    int hymn2Id = await txn.insert('cipher', {
      'title': 'How Great Thou Art',
      'author': 'Carl Boberg',
      'tempo': 'Medium',
      'music_key': 'D',
      'language': 'en',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Insert initial tags
    int classicTagId = await txn.insert('tag', {
      'title': 'Classic',
      'created_at': DateTime.now().toIso8601String(),
    });

    int popularTagId = await txn.insert('tag', {
      'title': 'Popular',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Link tags to ciphers
    await txn.insert('cipher_tags', {
      'cipher_id': hymn1Id,
      'tag_id': classicTagId,
      'created_at': DateTime.now().toIso8601String(),
    });

    await txn.insert('cipher_tags', {
      'cipher_id': hymn1Id,
      'tag_id': popularTagId,
      'created_at': DateTime.now().toIso8601String(),
    });

    await txn.insert('cipher_tags', {
      'cipher_id': hymn2Id,
      'tag_id': classicTagId,
      'created_at': DateTime.now().toIso8601String(),
    });

    // === ADD CIPHER MAPS WITH SONG STRUCTURE ===

    // Amazing Grace - Simple verse structure
    int amazingGraceMap1Id = await txn.insert('cipher_map', {
      'cipher_id': hymn1Id,
      'song_structure': 'V1,V2,V3,V4', // Four verses in sequence
      'transposed_key': null,
      'version_name': 'Original',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Amazing Grace - Abbreviated version for services
    int amazingGraceMap2Id = await txn.insert('cipher_map', {
      'cipher_id': hymn1Id,
      'song_structure': 'V1,V3,V4', // Skip verse 2 for shorter version
      'transposed_key': 'D',
      'version_name': 'Short Version (Key of D)',
      'created_at': DateTime.now().toIso8601String(),
    });

    // How Great Thou Art - Traditional verse/chorus structure
    int howGreatMap1Id = await txn.insert('cipher_map', {
      'cipher_id': hymn2Id,
      'song_structure': 'V1,C,V2,C,V3,C,V4,C', // Verse-Chorus pattern
      'transposed_key': null,
      'version_name': 'Standard',
      'created_at': DateTime.now().toIso8601String(),
    });

    // === ADD MAP CONTENT BLOCKS ===

    // Amazing Grace Content Blocks
    await txn.insert('map_content', {
      'map_id': amazingGraceMap1Id,
      'content_type': 'V1',
      'content_text': '''A[G]mazing [G7]Grace, how [C]sweet the [G]sound
That [G]saved a [D]wretch like [G]me
I [G]once was [G7]lost, but [C]now am [G]found
Was [G]blind, but [D]now I [G]see''',
    });

    await txn.insert('map_content', {
      'map_id': amazingGraceMap1Id,
      'content_type': 'V2',
      'content_text': ''''Twas [G]grace that [G7]taught my [C]heart to [G]fear
And [G]grace my [D]fears re[G]lieved
How [G]precious [G7]did that [C]grace ap[G]pear
The [G]hour I [D]first be[G]lieved''',
    });

    await txn.insert('map_content', {
      'map_id': amazingGraceMap1Id,
      'content_type': 'V3',
      'content_text': '''Through [G]many [G7]dangers, [C]toils and [G]snares
I [G]have al[D]ready [G]come
'Tis [G]grace hath [G7]brought me [C]safe thus [G]far
And [G]grace will [D]lead me [G]home''',
    });

    await txn.insert('map_content', {
      'map_id': amazingGraceMap1Id,
      'content_type': 'V4',
      'content_text': '''When [G]we've been [G7]there ten [C]thousand [G]years
Bright [G]shining [D]as the [G]sun
We've [G]no less [G7]days to [C]sing God's [G]praise
Than [G]when we [D]first be[G]gun''',
    });

    // Transposed version content (same blocks, different chords)
    await txn.insert('map_content', {
      'map_id': amazingGraceMap2Id,
      'content_type': 'V1',
      'content_text': '''A[D]mazing [D7]Grace, how [G]sweet the [D]sound
That [D]saved a [A]wretch like [D]me
I [D]once was [D7]lost, but [G]now am [D]found
Was [D]blind, but [A]now I [D]see''',
    });

    await txn.insert('map_content', {
      'map_id': amazingGraceMap2Id,
      'content_type': 'V3',
      'content_text': '''Through [D]many [D7]dangers, [G]toils and [D]snares
I [D]have al[A]ready [D]come
'Tis [D]grace hath [D7]brought me [G]safe thus [D]far
And [D]grace will [A]lead me [D]home''',
    });

    await txn.insert('map_content', {
      'map_id': amazingGraceMap2Id,
      'content_type': 'V4',
      'content_text': '''When [D]we've been [D7]there ten [G]thousand [D]years
Bright [D]shining [A]as the [D]sun
We've [D]no less [D7]days to [G]sing God's [D]praise
Than [D]when we [A]first be[D]gun''',
    });

    // How Great Thou Art Content Blocks
    await txn.insert('map_content', {
      'map_id': howGreatMap1Id,
      'content_type': 'V1',
      'content_text': '''O [D]Lord my God, when [G]I in awesome [D]wonder
Consider [D]all the [A]worlds Thy hands have [D]made
I see the [D]stars, I [G]hear the rolling [D]thunder
Thy power through[D]out the [A]universe dis[D]played''',
    });

    await txn.insert('map_content', {
      'map_id': howGreatMap1Id,
      'content_type': 'C',
      'content_text': '''Then sings my [D]soul, my [G]Saviour God, to [D]Thee
How great Thou [A]art, how great Thou [D]art
Then sings my [D]soul, my [G]Saviour God, to [D]Thee
How great Thou [A]art, how great Thou [D]art''',
    });

    await txn.insert('map_content', {
      'map_id': howGreatMap1Id,
      'content_type': 'V2',
      'content_text':
          '''When through the [D]woods and [G]forest glades I [D]wander
And hear the [D]birds sing [A]sweetly in the [D]trees
When I look [D]down from [G]lofty mountain [D]grandeur
And hear the [D]brook and [A]feel the gentle [D]breeze''',
    });

    await txn.insert('map_content', {
      'map_id': howGreatMap1Id,
      'content_type': 'V3',
      'content_text': '''And when I [D]think that [G]God, His Son not [D]sparing
Sent Him to [D]die, I [A]scarce can take it [D]in
That on the [D]cross, my [G]burden gladly [D]bearing
He bled and [D]died to [A]take away my [D]sin''',
    });

    await txn.insert('map_content', {
      'map_id': howGreatMap1Id,
      'content_type': 'V4',
      'content_text':
          '''When Christ shall [D]come with [G]shout of accla[D]mation
And take me [D]home, what [A]joy shall fill my [D]heart
Then I shall [D]bow in [G]humble adora[D]tion
And there pro[D]claim, my [A]God, how great Thou [D]art''',
    });
  });
}
