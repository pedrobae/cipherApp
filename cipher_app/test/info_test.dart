import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cipher_app/helpers/database.dart';
import 'package:cipher_app/repositories/info_repository.dart';
import 'package:cipher_app/models/domain/info_item.dart';

void main() {
  late DatabaseHelper dbHelper;
  late InfoRepository repository;

  setUpAll(() {
    // Initialize ffi for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbHelper = DatabaseHelper();
    repository = InfoRepository();
    // Reset database for each test
    await dbHelper.resetDatabase();
  });

  group('Info Repository Tests', () {
    test('should load seeded info items', () async {
      final infoItems = await repository.getAllInfo();
      
      // Verify that we have the seeded data
      expect(infoItems.isNotEmpty, true);
      expect(infoItems.length, greaterThanOrEqualTo(5)); // We seeded 5 items
      
      // Check for specific seeded items
      final studyAnnouncement = infoItems.firstWhere(
        (item) => item.title.contains('Nova Série de Estudos Bíblicos'),
      );
      expect(studyAnnouncement.type, InfoType.announcement);
      expect(studyAnnouncement.description.contains('Samuel'), true);
    });

    test('should filter by type correctly', () async {
      final announcements = await repository.getInfoByType('announcement');
      final events = await repository.getInfoByType('event');
      final news = await repository.getInfoByType('news');
      
      expect(announcements.isNotEmpty, true);
      expect(events.isNotEmpty, true);
      expect(news.isNotEmpty, true);
      
      // Verify all returned items have correct type
      for (final item in announcements) {
        expect(item.type, InfoType.announcement);
      }
      for (final item in events) {
        expect(item.type, InfoType.event);
      }
      for (final item in news) {
        expect(item.type, InfoType.news);
      }
    });

    test('should search info items', () async {
      final searchResults = await repository.searchInfo('oração');
      
      expect(searchResults.isNotEmpty, true);
      // Should find the prayer meeting
      expect(searchResults.any((item) => item.title.contains('Oração')), true);
    });

    test('should get recent info items', () async {
      final recentItems = await repository.getRecentInfo(limit: 3);
      
      expect(recentItems.length, lessThanOrEqualTo(3));
      
      // Verify items are ordered by published date (newest first)
      for (int i = 0; i < recentItems.length - 1; i++) {
        expect(
          recentItems[i].publishedAt.isAfter(recentItems[i + 1].publishedAt) ||
          recentItems[i].publishedAt.isAtSameMomentAs(recentItems[i + 1].publishedAt),
          true,
        );
      }
    });

    test('should create new info item', () async {
      final newItem = InfoItem(
        id: 'test_001',
        title: 'Teste de Criação',
        description: 'Item de teste criado durante os testes',
        publishedAt: DateTime.now(),
        type: InfoType.news,
        metadata: {'category': 'teste'},
      );

      await repository.createInfo(newItem);
      
      final retrieved = await repository.getInfoById('test_001');
      expect(retrieved, isNotNull);
      expect(retrieved!.title, 'Teste de Criação');
      expect(retrieved.type, InfoType.news);
    });

    test('should update existing info item', () async {
      // Get an existing item
      final allItems = await repository.getAllInfo();
      final firstItem = allItems.first;
      
      // Create updated version
      final updatedItem = InfoItem(
        id: firstItem.id,
        title: 'Título Atualizado',
        description: firstItem.description,
        publishedAt: firstItem.publishedAt,
        type: firstItem.type,
      );

      await repository.updateInfo(updatedItem);
      
      final retrieved = await repository.getInfoById(firstItem.id);
      expect(retrieved!.title, 'Título Atualizado');
    });

    test('should delete info item', () async {
      final allItems = await repository.getAllInfo();
      final itemToDelete = allItems.first;
      
      await repository.deleteInfo(itemToDelete.id);
      
      final retrieved = await repository.getInfoById(itemToDelete.id);
      expect(retrieved, isNull);
    });
  });

  tearDown(() async {
    await dbHelper.close();
  });
}
