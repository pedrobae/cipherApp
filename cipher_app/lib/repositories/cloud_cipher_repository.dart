import 'package:cipher_app/services/firestore_service.dart';
import 'package:cipher_app/models/dtos/cipher_dto.dart';
import 'package:cipher_app/models/dtos/version_dto.dart';
import 'package:flutter/foundation.dart';

class CloudCipherRepository {
  final FirestoreService _firestoreService = FirestoreService();

  // For now the user has no access to writing ciphers to the cloud. (Read-only)

  /// ===== READ =====
  /// Fetch popular ciphers from Firestore
  Future<List<CipherDto>> getPopularCiphers() async {
    final snapshot = await _firestoreService.fetchDocumentById(
      collectionPath: 'stats/',
      documentId: 'popularCiphers',
    );

    List<CipherDto> ciphers =
        ((snapshot!.data() as Map<String, dynamic>)['ciphers'] as List)
            .map<CipherDto>((map) => CipherDto.fromMap(map))
            .toList();

    return ciphers;
  }

  Future<List<VersionDto>> getVersionsOfCipher(String cipherId) async {
    final snapshot = await _firestoreService.fetchSubCollectionDocuments(
      parentCollectionPath: 'publicCiphers',
      parentDocumentId: cipherId,
      subCollectionPath: 'versions',
    );

    return snapshot
        .map(
          (version) =>
              VersionDto.fromMap(version.data() as Map<String, dynamic>),
        )
        .toList();
  }

  /// Cost-effective single query search (SEARCH TEXT field)
  Future<List<CipherDto>?> searchCiphers(String query) async {
    try {
      final lowerQuery = query.toLowerCase().trim();

      // Single query approach - search in combined searchText field
      // Firebase document should have: searchText: "amazing grace john newton hymn classic worship"
      final results = await _firestoreService.fetchDocuments(
        collectionPath: 'publicCiphers',
        filters: {
          'searchText': lowerQuery,
        }, // Single field with all searchable content
        limit: 25,
      );

      return results
          .map((doc) => CipherDto.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching ciphers: $e');
      }
      return null;
    }
  }

  /// Cost-optimized search with cascading fallback
  Future<List<CipherDto>?> searchCiphersCascading(String query) async {
    try {
      final lowerQuery = query.toLowerCase().trim();
      List<CipherDto> results = [];

      // 1. Search in title first (most relevant, 1 read)
      final titleResults = await _firestoreService.fetchDocuments(
        collectionPath: 'publicCiphers',
        filters: {'titleLower': lowerQuery},
        limit: 25,
      );

      results.addAll(
        titleResults
            .map((doc) => CipherDto.fromMap(doc.data() as Map<String, dynamic>))
            .toList(),
      );

      // 2. If we have enough results from title, return early
      if (results.length >= 15) {
        return results.take(25).toList();
      }

      // 3. Search in author only if needed (2nd read)
      final authorResults = await _firestoreService.fetchDocuments(
        collectionPath: 'publicCiphers',
        filters: {'authorLower': lowerQuery},
        limit: 25 - results.length,
      );

      // Add unique results (using document ID from Firestore)
      final existingIds = titleResults.map((doc) => doc.id).toSet();
      results.addAll(
        authorResults
            .where((doc) => !existingIds.contains(doc.id))
            .map((doc) => CipherDto.fromMap(doc.data() as Map<String, dynamic>))
            .toList(),
      );

      // 4. Search tags only if still need more results (3rd read - rare)
      if (results.length < 10) {
        final tagResults = await _firestoreService.fetchDocuments(
          collectionPath: 'publicCiphers',
          filters: {'primaryTag': lowerQuery}, // Single tag field
          limit: 25 - results.length,
        );

        final allExistingIds = [
          ...titleResults,
          ...authorResults,
        ].map((doc) => doc.id).toSet();
        results.addAll(
          tagResults
              .where((doc) => !allExistingIds.contains(doc.id))
              .map(
                (doc) => CipherDto.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
      }

      return results.take(25).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching ciphers: $e');
      }
      return null;
    }
  }
}
