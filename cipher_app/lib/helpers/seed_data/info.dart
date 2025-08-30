import 'dart:async';
import 'package:sqflite/sqflite.dart';

Future<void> seedInfoDatabase(Database db) async {
  await db.transaction((txn) async {
    // Insert sample info items based on mock_info.json
    
    // Info item 1 - Study announcement
    await txn.insert('app_info', {
      'remote_id': 'info001',
      'title': 'Nova Série de Estudos Bíblicos',
      'description': 'Começamos uma nova série sobre os livros de Samuel. Toda quarta-feira às 19h30.',
      'type': 'announcement',
      'priority': 3, // high priority
      'published_at': '2025-08-21T10:00:00Z',
      'language': 'por',
      'is_dismissible': 1,
      'created_at': DateTime.now().toIso8601String(),
      'cache_expires_at': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'is_stale': 0,
    });

    // Info item 2 - Special event
    await txn.insert('app_info', {
      'remote_id': 'info002',
      'title': 'Culto de Ação de Graças',
      'description': 'Domingo especial de ação de graças com testemunhos e louvor.',
      'content': '{"date": "2025-08-27T09:00:00Z", "location": "Templo Principal"}',
      'type': 'event',
      'priority': 2, // medium priority
      'published_at': '2025-08-20T10:00:00Z',
      'language': 'por',
      'is_dismissible': 1,
      'created_at': DateTime.now().toIso8601String(),
      'cache_expires_at': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'is_stale': 0,
    });

    // Info item 3 - Prayer meeting news
    await txn.insert('app_info', {
      'remote_id': 'info003',
      'title': 'Reunião de Oração',
      'description': 'Reunião de oração na casa do irmão João.',
      'content': '{"date": "2025-08-29T19:00:00Z", "location": "Casa do Irmão João"}',
      'type': 'news',
      'priority': 1, // low priority
      'published_at': '2025-08-22T10:00:00Z',
      'language': 'por',
      'is_dismissible': 1,
      'created_at': DateTime.now().toIso8601String(),
      'cache_expires_at': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'is_stale': 0,
    });

    // Additional sample info items for demonstration
    await txn.insert('app_info', {
      'remote_id': 'info004',
      'title': 'Ensaio do Coral',
      'description': 'Ensaio especial para o coral da igreja. Participação obrigatória para todos os membros.',
      'content': '{"date": "2025-08-26T19:30:00Z", "location": "Sala de Música"}',
      'type': 'announcement',
      'priority': 2,
      'published_at': '2025-08-23T15:00:00Z',
      'language': 'por',
      'is_dismissible': 1,
      'created_at': DateTime.now().toIso8601String(),
      'cache_expires_at': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'is_stale': 0,
    });

    await txn.insert('app_info', {
      'remote_id': 'info005',
      'title': 'Retiro Jovens',
      'description': 'Retiro especial para jovens de 15 a 25 anos. Inscrições abertas!',
      'content': '{"date": "2025-09-05T08:00:00Z", "location": "Sítio da Paz", "deadline": "2025-08-30T23:59:59Z"}',
      'type': 'event',
      'priority': 3,
      'published_at': '2025-08-19T10:00:00Z',
      'expires_at': '2025-09-05T23:59:59Z',
      'language': 'por',
      'is_dismissible': 1,
      'created_at': DateTime.now().toIso8601String(),
      'cache_expires_at': DateTime.now().add(const Duration(days: 45)).toIso8601String(),
      'is_stale': 0,
    });
  });
}
