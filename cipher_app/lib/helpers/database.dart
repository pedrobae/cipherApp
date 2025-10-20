import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'seed_data/seed_database.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'cipher_app.db');

      bool isNewDatabase = !await databaseFactory.databaseExists(path);

      final db = await openDatabase(
        path,
        version: 6,
        onCreate: _onCreate, // This will seed the database
        onUpgrade: _onUpgrade, // Handle migrations
      );

      // Only seed if database existed but is empty (edge case)
      if (!isNewDatabase) {
        final cipherCount = await db.rawQuery(
          'SELECT COUNT(*) as count FROM cipher',
        );
        final count = cipherCount.first['count'] as int;

        if (count == 0) {
          await seedDatabase(db);
        }
      }

      return db;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create tag table
    await db.execute('''
      CREATE TABLE tag (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create cipher table
    await db.execute('''
      CREATE TABLE cipher (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT,
        tempo TEXT,
        music_key TEXT,
        language TEXT DEFAULT 'por',
        firebase_id TEXT,
        is_deleted BOOLEAN DEFAULT 0,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create cipher_tags junction table
    await db.execute('''
      CREATE TABLE cipher_tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tag_id INTEGER NOT NULL,
        cipher_id INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (tag_id) REFERENCES tag (id) ON DELETE CASCADE,
        FOREIGN KEY (cipher_id) REFERENCES cipher (id) ON DELETE CASCADE,
        UNIQUE(tag_id, cipher_id)
      )
    ''');

    // Create version table (renamed from cipher_map)
    await db.execute('''
      CREATE TABLE version (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cipher_id INTEGER NOT NULL,
        song_structure TEXT NOT NULL,
        transposed_key TEXT,
        version_name TEXT,
        firebase_cipher_id TEXT,
        firebase_id TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (cipher_id) REFERENCES cipher (id) ON DELETE CASCADE
      )
    ''');

    // Create section table (renamed from map_content)
    await db.execute('''
      CREATE TABLE section (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        version_id INTEGER NOT NULL,
        content_type TEXT NOT NULL,
        content_code VARCHAR NOT NULL,
        content_text TEXT NOT NULL,
        content_color TEXT,
        FOREIGN KEY (version_id) REFERENCES version (id) ON DELETE CASCADE
      )
    ''');

    // Create user table
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        mail TEXT UNIQUE NOT NULL,
        profile_photo TEXT,
        google_id TEXT UNIQUE,
        firebase_id TEXT UNIQUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        is_active BOOLEAN DEFAULT 1
      )
    ''');

    // Create playlist table
    await db.execute('''
      CREATE TABLE playlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        author_id STRING NOT NULL,
        firebase_id TEXT UNIQUE,
        is_public BOOLEAN DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (author_id) REFERENCES user (id) ON DELETE CASCADE
      )
    ''');

    // Create playlist_version table (playlists contain specific cipher versions)
    await db.execute('''
      CREATE TABLE playlist_version (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        version_id INTEGER NOT NULL,
        playlist_id INTEGER NOT NULL,
        includer_id INTEGER NOT NULL,
        firebase_content_id TEXT,
        position INTEGER NOT NULL,
        included_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (version_id) REFERENCES version (id) ON DELETE CASCADE,
        FOREIGN KEY (playlist_id) REFERENCES playlist (id) ON DELETE CASCADE,
        FOREIGN KEY (includer_id) REFERENCES user (id) ON DELETE CASCADE,
        UNIQUE(playlist_id, position)
      )
    ''');

    // Create user_playlist table for collaborators
    await db.execute('''
      CREATE TABLE user_playlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        playlist_id INTEGER NOT NULL,
        role TEXT NOT NULL DEFAULT 'collaborator',
        added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        added_by INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE,
        FOREIGN KEY (playlist_id) REFERENCES playlist (id) ON DELETE CASCADE,
        FOREIGN KEY (added_by) REFERENCES user (id) ON DELETE CASCADE,
        UNIQUE(user_id, playlist_id)
      )
    ''');

    // Create playlist_text table, for written sections
    await db.execute('''
      CREATE TABLE playlist_text (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        playlist_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        firebase_id TEXT,
        position INTEGER NOT NULL DEFAULT 0,
        added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        added_by INTEGER NOT NULL,
        FOREIGN KEY (playlist_id) REFERENCES playlist (id) ON DELETE CASCADE,
        FOREIGN KEY (added_by) REFERENCES user (id) ON DELETE CASCADE
      )
    ''');

    // Create app_info table for cached announcements/news
    await db.execute('''
      CREATE TABLE app_info (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firebase_id TEXT UNIQUE,
        title TEXT NOT NULL,
        description TEXT,
        content TEXT,
        type TEXT NOT NULL,
        priority INTEGER DEFAULT 0,
        published_at TIMESTAMP,
        expires_at TIMESTAMP,
        source_url TEXT,
        thumbnail_path TEXT,
        language TEXT DEFAULT 'por',
        is_dismissible BOOLEAN DEFAULT 1,
        last_fetched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        cache_expires_at TIMESTAMP,
        is_stale BOOLEAN DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create indexes for better performance
    await db.execute(
      'CREATE INDEX idx_cipher_tags_cipher_id ON cipher_tags(cipher_id)',
    );
    await db.execute(
      'CREATE INDEX idx_cipher_tags_tag_id ON cipher_tags(tag_id)',
    );
    await db.execute(
      'CREATE INDEX idx_version_cipher_id ON version(cipher_id)',
    );
    await db.execute(
      'CREATE INDEX idx_section_version_id ON section(version_id)',
    );
    await db.execute(
      'CREATE INDEX idx_playlist_author_id ON playlist(author_id)',
    );
    await db.execute(
      'CREATE INDEX idx_playlist_version_playlist_id ON playlist_version(playlist_id)',
    );
    await db.execute(
      'CREATE INDEX idx_playlist_version_version_id ON playlist_version(version_id)',
    );
    await db.execute(
      'CREATE INDEX idx_user_playlist_user_id ON user_playlist(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_user_playlist_playlist_id ON user_playlist(playlist_id)',
    );
    await db.execute('CREATE INDEX idx_app_info_type ON app_info(type)');
    await db.execute(
      'CREATE INDEX idx_app_info_published_at ON app_info(published_at)',
    );
    await db.execute(
      'CREATE INDEX idx_app_info_expires_at ON app_info(expires_at)',
    );
    await db.execute(
      'CREATE INDEX idx_app_info_priority ON app_info(priority)',
    );
    // For user lookups
    await db.execute('CREATE INDEX idx_user_google_id ON user(google_id)');
    await db.execute('CREATE INDEX idx_user_mail ON user(mail)');
    await db.execute(
      'CREATE UNIQUE INDEX idx_user_firebase_id ON user(firebase_id)',
    );
    // For cipher lookups
    await db.execute(
      'CREATE UNIQUE INDEX idx_cipher_firebase_id ON cipher(firebase_id)',
    );
    // For version lookups
    await db.execute(
      'CREATE UNIQUE INDEX idx_version_firebase_id ON version(firebase_id)',
    );
    await db.execute(
      'CREATE INDEX idx_version_firebase_cipher_id ON version(firebase_cipher_id)',
    );
    // For content queries
    await db.execute(
      'CREATE INDEX idx_section_content_type OwN section(content_type)',
    );

    // Seed the database with initial data
    // await seedDatabase(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations between database versions

    if (oldVersion < 4) {
      // Migration from version 3 to 4: Add firebase_id column to cipher table
      await db.execute('ALTER TABLE cipher ADD COLUMN firebase_id TEXT');
      await db.execute(
        'CREATE UNIQUE INDEX idx_cipher_firebase_id ON cipher(firebase_id)',
      );
      await db.execute(
        'ALTER TABLE version ADD COLUMN firebase_cipher_id TEXT',
      );
      await db.execute('ALTER TABLE version ADD COLUMN firebase_id TEXT');
      await db.execute(
        'CREATE UNIQUE INDEX idx_version_firebase_id ON version(firebase_id)',
      );
      await db.execute(
        'CREATE INDEX idx_version_firebase_cipher_id ON version(firebase_cipher_id)',
      );
    }

    if (oldVersion < 5) {
      // Migration from version 4 to 5: Remove unique constraint on playlist_version position
      // SQLite doesn't support DROP CONSTRAINT, so we need to recreate the table

      // 1. Create new table without the constraint
      await db.execute('''
        CREATE TABLE playlist_version_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          version_id INTEGER NOT NULL,
          playlist_id INTEGER NOT NULL,
          includer_id INTEGER NOT NULL,
          position INTEGER NOT NULL,
          included_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (version_id) REFERENCES version (id) ON DELETE CASCADE,
          FOREIGN KEY (playlist_id) REFERENCES playlist (id) ON DELETE CASCADE,
          FOREIGN KEY (includer_id) REFERENCES user (id) ON DELETE CASCADE,
          UNIQUE(position, playlist_id)
        )
      ''');

      // 2. Copy data from old table to new table
      await db.execute('''
        INSERT INTO playlist_version_new (id, version_id, playlist_id, includer_id, position, included_at)
        SELECT id, version_id, playlist_id, includer_id, position, included_at
        FROM playlist_version
      ''');

      // 3. Drop old table
      await db.execute('DROP TABLE playlist_version');

      // 4. Rename new table to original name
      await db.execute(
        'ALTER TABLE playlist_version_new RENAME TO playlist_version',
      );

      // 5. Recreate indexes
      await db.execute(
        'CREATE INDEX idx_playlist_version_playlist_id ON playlist_version(playlist_id)',
      );
      await db.execute(
        'CREATE INDEX idx_playlist_version_version_id ON playlist_version(version_id)',
      );
    }
    if (oldVersion < 6) {
      // Add firebase_id columns for cloud sync
      await db.execute('ALTER TABLE user ADD COLUMN firebase_id TEXT');
      await db.execute('ALTER TABLE playlist ADD COLUMN firebase_id TEXT');
      await db.execute(
        'ALTER TABLE playlist_version ADD COLUMN firebase_content_id TEXT',
      );
      await db.execute('ALTER TABLE playlist_text ADD COLUMN firebase_id TEXT');

      // Add indexes for firebase_id columns
      await db.execute(
        'CREATE UNIQUE INDEX idx_user_firebase_id ON user(firebase_id)',
      );
      await db.execute(
        'CREATE UNIQUE INDEX idx_playlist_firebase_id ON playlist(firebase_id)',
      );
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // Helper method to reset database (for development)
  Future<void> resetDatabase() async {
    try {
      // First close any existing database connection
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // Get the database path
      String path = join(await getDatabasesPath(), 'cipher_app.db');

      // Delete the database file completely
      await databaseFactory.deleteDatabase(path);

      // Re-initialize database
      await database;
    } catch (e) {
      rethrow;
    }
  }
}
