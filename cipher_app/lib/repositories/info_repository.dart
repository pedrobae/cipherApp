import 'dart:convert';
import '../helpers/database_helper.dart';
import '../models/domain/info_item.dart';

class InfoRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<InfoItem>> getAllInfo() async {
    final db = await _databaseHelper.database;
    
    final results = await db.query(
      'app_info',
      orderBy: 'published_at DESC, priority DESC',
    );

    return results.map((row) => _mapRowToInfoItem(row)).toList();
  }

  Future<List<InfoItem>> getInfoByType(String type) async {
    final db = await _databaseHelper.database;
    
    final results = await db.query(
      'app_info',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'published_at DESC, priority DESC',
    );

    return results.map((row) => _mapRowToInfoItem(row)).toList();
  }

  Future<List<InfoItem>> getRecentInfo({int limit = 5}) async {
    final db = await _databaseHelper.database;
    
    final results = await db.query(
      'app_info',
      orderBy: 'published_at DESC',
      limit: limit,
    );

    return results.map((row) => _mapRowToInfoItem(row)).toList();
  }

  Future<InfoItem?> getInfoById(String remoteId) async {
    final db = await _databaseHelper.database;
    
    final results = await db.query(
      'app_info',
      where: 'remote_id = ?',
      whereArgs: [remoteId],
      limit: 1,
    );

    if (results.isEmpty) return null;
    
    return _mapRowToInfoItem(results.first);
  }

  Future<int> createInfo(InfoItem infoItem) async {
    final db = await _databaseHelper.database;
    
    return await db.insert('app_info', _mapInfoItemToRow(infoItem));
  }

  Future<void> updateInfo(InfoItem infoItem) async {
    final db = await _databaseHelper.database;
    
    await db.update(
      'app_info',
      _mapInfoItemToRow(infoItem),
      where: 'remote_id = ?',
      whereArgs: [infoItem.id],
    );
  }

  Future<void> deleteInfo(String remoteId) async {
    final db = await _databaseHelper.database;
    
    await db.delete(
      'app_info',
      where: 'remote_id = ?',
      whereArgs: [remoteId],
    );
  }

  Future<List<InfoItem>> searchInfo(String query) async {
    final db = await _databaseHelper.database;
    
    final results = await db.query(
      'app_info',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'published_at DESC, priority DESC',
    );

    return results.map((row) => _mapRowToInfoItem(row)).toList();
  }

  Future<void> markAsStale(String remoteId) async {
    final db = await _databaseHelper.database;
    
    await db.update(
      'app_info',
      {'is_stale': 1},
      where: 'remote_id = ?',
      whereArgs: [remoteId],
    );
  }

  Future<void> clearExpiredInfo() async {
    final db = await _databaseHelper.database;
    
    await db.delete(
      'app_info',
      where: 'expires_at IS NOT NULL AND expires_at < ?',
      whereArgs: [DateTime.now().toIso8601String()],
    );
  }

  // Helper method to map database row to InfoItem
  InfoItem _mapRowToInfoItem(Map<String, dynamic> row) {
    Map<String, dynamic>? highlight;
    Map<String, dynamic>? metadata;

    // Parse content JSON if it exists
    if (row['content'] != null && row['content'].isNotEmpty) {
      try {
        final contentMap = json.decode(row['content']);
        if (contentMap.containsKey('date') || contentMap.containsKey('location')) {
          highlight = contentMap;
        } else {
          metadata = contentMap;
        }
      } catch (e) {
        // If JSON parsing fails, treat as metadata
        metadata = {'raw_content': row['content']};
      }
    }

    // Add priority to metadata if it exists
    if (row['priority'] != null) {
      metadata ??= {};
      metadata['priority'] = _priorityToString(row['priority'] as int);
    }

    return InfoItem(
      id: row['remote_id'] as String,
      title: row['title'] as String,
      description: row['description'] as String? ?? '',
      imageUrl: row['thumbnail_path'] as String?,
      publishedAt: DateTime.parse(row['published_at'] as String),
      type: InfoType.values.firstWhere(
        (e) => e.name == row['type'],
        orElse: () => InfoType.news,
      ),
      highlight: highlight,
      metadata: metadata,
      link: row['source_url'] as String?,
    );
  }

  // Helper method to map InfoItem to database row
  Map<String, dynamic> _mapInfoItemToRow(InfoItem infoItem) {
    String? contentJson;
    int priority = 1; // default priority

    // Handle highlight and metadata
    if (infoItem.highlight != null) {
      contentJson = json.encode(infoItem.highlight);
    } else if (infoItem.metadata != null) {
      // Extract priority if it exists in metadata
      if (infoItem.metadata!.containsKey('priority')) {
        priority = _stringToPriority(infoItem.metadata!['priority']);
        final metadataWithoutPriority = Map<String, dynamic>.from(infoItem.metadata!);
        metadataWithoutPriority.remove('priority');
        if (metadataWithoutPriority.isNotEmpty) {
          contentJson = json.encode(metadataWithoutPriority);
        }
      } else {
        contentJson = json.encode(infoItem.metadata);
      }
    }

    return {
      'remote_id': infoItem.id,
      'title': infoItem.title,
      'description': infoItem.description,
      'content': contentJson,
      'type': infoItem.type.name,
      'priority': priority,
      'published_at': infoItem.publishedAt.toIso8601String(),
      'source_url': infoItem.link,
      'thumbnail_path': infoItem.imageUrl,
      'language': 'por', // Default to Portuguese
      'is_dismissible': 1,
      'created_at': DateTime.now().toIso8601String(),
      'last_fetched_at': DateTime.now().toIso8601String(),
      'cache_expires_at': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'is_stale': 0,
    };
  }

  String _priorityToString(int priority) {
    switch (priority) {
      case 3:
        return 'high';
      case 2:
        return 'medium';
      case 1:
      default:
        return 'low';
    }
  }

  int _stringToPriority(dynamic priority) {
    if (priority is int) return priority;
    
    switch (priority.toString().toLowerCase()) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
      default:
        return 1;
    }
  }
}
