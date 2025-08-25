import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cipher_app/repositories/cipher_repository.dart';
import 'package:cipher_app/helpers/database_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('CipherRepository Tests', () {
    late CipherRepository repository;
    late DatabaseHelper dbHelper;

    setUp(() async {
      dbHelper = DatabaseHelper();
      await dbHelper.resetDatabase(); // This will recreate and seed the database
      repository = CipherRepository();
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('should load seeded ciphers', () async {
      final ciphers = await repository.getAllCiphers();
      
      expect(ciphers.length, 2); // Amazing Grace + How Great Thou Art
      expect(ciphers.any((c) => c.title == 'Amazing Grace'), true);
      expect(ciphers.any((c) => c.title == 'How Great Thou Art'), true);
    });

    test('should get cipher by ID with maps and content', () async {
      final ciphers = await repository.getAllCiphers();
      final amazingGrace = ciphers.firstWhere((c) => c.title == 'Amazing Grace');
      
      final cipher = await repository.getCipherById(amazingGrace.id!);
      
      expect(cipher, isNotNull);
      expect(cipher!.title, 'Amazing Grace');
      expect(cipher.maps.length, 2); // Original + Short version
      expect(cipher.maps.first.content.isNotEmpty, true);
    });

    test('should soft delete cipher', () async {
      final ciphers = await repository.getAllCiphers();
      final cipherId = ciphers.first.id!;
      
      await repository.deleteCipher(cipherId);
      
      final remainingCiphers = await repository.getAllCiphers();
      expect(remainingCiphers.length, 1); // One less cipher
      expect(remainingCiphers.any((c) => c.id == cipherId), false);
    });

    test('should get cipher maps with content', () async {
      final ciphers = await repository.getAllCiphers();
      final howGreat = ciphers.firstWhere((c) => c.title == 'How Great Thou Art');
      
      final maps = await repository.getCipherMaps(howGreat.id!);
      
      expect(maps.length, 1);
      expect(maps.first.songStructure, 'V1,C,V2,C,V3,C,V4,C');
      expect(maps.first.content.length, 5); // V1, C, V2, V3, V4
    });

    test('should get map content', () async {
      final ciphers = await repository.getAllCiphers();
      final cipher = ciphers.first;
      final maps = await repository.getCipherMaps(cipher.id!);
      
      final content = await repository.getMapContent(maps.first.id!);
      
      expect(content.isNotEmpty, true);
      expect(content.any((c) => c.contentType == 'V1'), true);
      expect(content.first.contentText.contains('['), true); // Has chords
    });
  });
}

