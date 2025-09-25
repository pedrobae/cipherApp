import 'package:flutter_test/flutter_test.dart';
import 'package:cipher_app/repositories/cipher_repository.dart';
import 'package:cipher_app/helpers/database.dart';
import 'package:cipher_app/helpers/database_factory.dart';

void main() {
  setUpAll(() {
    DatabaseFactoryHelper.initializeForTesting();
  });

  group('CipherRepository Tests', () {
    late CipherRepository repository;
    late DatabaseHelper dbHelper;

    setUp(() async {
      dbHelper = DatabaseHelper();
      await dbHelper
          .resetDatabase(); // This will recreate and seed the database
      repository = CipherRepository();
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('should load seeded ciphers', () async {
      final ciphers = await repository.getAllCiphersPruned();

      expect(
        ciphers.length,
        4,
      ); // Amazing Grace + How Great Thou Art + Holy Holy Holy + Be Thou My Vision
      expect(ciphers.any((c) => c.title == 'Amazing Grace'), true);
      expect(ciphers.any((c) => c.title == 'How Great Thou Art'), true);
    });

    test('should get cipher by ID with maps and content', () async {
      final ciphers = await repository.getAllCiphersPruned();
      final amazingGrace = ciphers.firstWhere(
        (c) => c.title == 'Amazing Grace',
      );

      final cipher = await repository.getCipherById(amazingGrace.id!);

      expect(cipher, isNotNull);
      expect(cipher!.title, 'Amazing Grace');
      expect(cipher.versions.length, 2); // Original + Short version
      expect(cipher.versions.first.sections != null, true);
    });

    test('should soft delete cipher', () async {
      final ciphers = await repository.getAllCiphersPruned();
      final cipherId = ciphers.first.id!;

      await repository.deleteCipher(cipherId);

      final remainingCiphers = await repository.getAllCiphersPruned();
      expect(remainingCiphers.length, 3); // One less cipher (4-1=3)
      expect(remainingCiphers.any((c) => c.id == cipherId), false);
    });

    test('should get cipher maps with section', () async {
      final ciphers = await repository.getAllCiphersPruned();
      final howGreat = ciphers.firstWhere(
        (c) => c.title == 'How Great Thou Art',
      );

      final maps = await repository.getCipherVersions(howGreat.id!);

      expect(maps.length, 1);
      expect(maps.first.songStructure, 'V1,C,V2,C,V3,C,V4,C');
      expect(maps.first.sections!.keys.length, 5); // V1, C, V2, V3, V4
    });

    test('should get map sections', () async {
      final ciphers = await repository.getAllCiphersPruned();
      final cipher = ciphers.firstWhere((c) => c.title == 'Amazing Grace');
      final maps = await repository.getCipherVersions(cipher.id!);

      final sections = await repository.getAllSections(maps.first.id!);

      expect(sections.isNotEmpty, true);
      expect(sections.containsKey('V1'), true);
      expect(sections['V1']?.contentText.contains('['), true); // Has chords
    });
  });
}
