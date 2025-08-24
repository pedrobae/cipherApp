import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cipher_app/repositories/cipher_repository.dart';
import 'package:cipher_app/models/domain/cipher.dart';
import 'package:cipher_app/database/database_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('CipherRepository Tests', () {
    late CipherRepository repository;
    late DatabaseHelper dbHelper;

    setUp(() async {
      // Create a fresh database for each test
      dbHelper = DatabaseHelper();
      await dbHelper.resetDatabase();
      
      // Create repository after database is reset
      repository = CipherRepository();
    });

    tearDown(() async {
      // Clean up after each test
      await dbHelper.resetDatabase();
    });

    test('should start with empty database', () async {
      final ciphers = await repository.getAllCiphers();
      expect(ciphers, isEmpty);
    });

    test('should insert cipher successfully', () async {
      final cipher = Cipher(
        id: 1,
        title: 'Test Song',
        author: 'Test Author',
        tempo: 'Medium',
        tags: ['test'],
        musicKey: 'C',
        language: 'en',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isLocal: true,
        maps: [],
      );

      final id = await repository.insertCipher(cipher);
      expect(id, greaterThan(0));

      final allCiphers = await repository.getAllCiphers();
      expect(allCiphers.length, 1);
      expect(allCiphers.first.title, 'Test Song');
    });

    test('should update cipher successfully', () async {
      // First insert
      final cipher = Cipher(
        id: 1,
        title: 'Original Title',
        author: 'Test Author',
        tempo: 'Medium',
        tags: ['test'],
        musicKey: 'C',
        language: 'en',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isLocal: true,
        maps: [],
      );

      await repository.insertCipher(cipher);

      // Then update
      final updatedCipher = cipher.copyWith(title: 'Updated Title');
      final result = await repository.updateCipher(updatedCipher);
      
      expect(result, 1);

      final allCiphers = await repository.getAllCiphers();
      expect(allCiphers.first.title, 'Updated Title');
    });

    test('should delete cipher successfully', () async {
      // Insert first
      final cipher = Cipher(
        id: 1,
        title: 'Test Song',
        author: 'Test Author',
        tempo: 'Medium',
        tags: ['test'],
        musicKey: 'C',
        language: 'en',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isLocal: true,
        maps: [],
      );

      final id = await repository.insertCipher(cipher);
      
      // Delete
      final result = await repository.deleteCipher(id);
      expect(result, 1);

      final allCiphers = await repository.getAllCiphers();
      expect(allCiphers, isEmpty);
    });
  });
}

