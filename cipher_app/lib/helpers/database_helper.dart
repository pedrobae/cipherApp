import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    String path = join(await getDatabasesPath(), 'cipher_app.db');

    bool isNewDatabase = !await databaseFactory.databaseExists(path);
    
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

     if (isNewDatabase) {
      await _seedDatabase(db);
    }

    return db;
  }

  Future<void> _seedDatabase(Database db) async {
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
        'created_at': DateTime.now().toIso8601String()
      });
      
      int popularTagId = await txn.insert('tag', {
        'title': 'Popular', 
        'created_at': DateTime.now().toIso8601String()
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
    });
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

    // Create cipher_map table
    await db.execute('''
      CREATE TABLE cipher_map (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cipher_id INTEGER NOT NULL,
        map_order TEXT NOT NULL,
        transposed_key TEXT,
        version_name TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (cipher_id) REFERENCES cipher (id) ON DELETE CASCADE
      )
    ''');

    // Create map_content table
    await db.execute('''
      CREATE TABLE map_content (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        map_id INTEGER NOT NULL,
        content_type VARCHAR NOT NULL,
        content_text TEXT NOT NULL,
        FOREIGN KEY (map_id) REFERENCES cipher_map (id) ON DELETE CASCADE
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
        author_id INTEGER NOT NULL,
        is_public BOOLEAN DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (author_id) REFERENCES user (id) ON DELETE CASCADE
      )
    ''');

    // Create playlist_cipher table
    await db.execute('''
      CREATE TABLE playlist_cipher (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cipher_id INTEGER NOT NULL,
        playlist_id INTEGER NOT NULL,
        includer_id INTEGER NOT NULL,
        position INTEGER NOT NULL,
        included_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (cipher_id) REFERENCES cipher (id) ON DELETE CASCADE,
        FOREIGN KEY (playlist_id) REFERENCES playlist (id) ON DELETE CASCADE,
        FOREIGN KEY (includer_id) REFERENCES user (id) ON DELETE CASCADE,
        UNIQUE(playlist_id, cipher_id),
        UNIQUE(playlist_id, position)
      )
    ''');

    // Create app_info table for cached announcements/news
    await db.execute('''
      CREATE TABLE app_info (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remote_id TEXT UNIQUE,
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
    await db.execute('CREATE INDEX idx_cipher_tags_cipher_id ON cipher_tags(cipher_id)');
    await db.execute('CREATE INDEX idx_cipher_tags_tag_id ON cipher_tags(tag_id)');
    await db.execute('CREATE INDEX idx_cipher_map_cipher_id ON cipher_map(cipher_id)');
    await db.execute('CREATE INDEX idx_map_content_map_id ON map_content(map_id)');
    await db.execute('CREATE INDEX idx_playlist_author_id ON playlist(author_id)');
    await db.execute('CREATE INDEX idx_playlist_cipher_playlist_id ON playlist_cipher(playlist_id)');
    await db.execute('CREATE INDEX idx_playlist_cipher_cipher_id ON playlist_cipher(cipher_id)');
    await db.execute('CREATE INDEX idx_app_info_type ON app_info(type)');
    await db.execute('CREATE INDEX idx_app_info_published_at ON app_info(published_at)');
    await db.execute('CREATE INDEX idx_app_info_expires_at ON app_info(expires_at)');
    await db.execute('CREATE INDEX idx_app_info_priority ON app_info(priority)');
    // For user lookups
    await db.execute('CREATE INDEX idx_user_google_id ON user(google_id)');
    await db.execute('CREATE INDEX idx_user_mail ON user(mail)');
    // For content queries
    await db.execute('CREATE INDEX idx_map_content_type ON map_content(content_type)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    // For example, if you need to add new columns or tables in future versions
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