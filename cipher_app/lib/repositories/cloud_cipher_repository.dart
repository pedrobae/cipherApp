import 'package:cipher_app/models/domain/cipher/cipher.dart';
import 'package:cipher_app/models/domain/cipher/version.dart';
import 'package:cipher_app/services/firestore_service.dart';
import 'package:cipher_app/services/auth_service.dart';
import 'package:cipher_app/models/dtos/cipher_dto.dart';
import 'package:cipher_app/models/dtos/version_dto.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class CloudCipherRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  // ===== PERMISSION HELPERS =====
  Future<void> _requireAdmin() async {
    if (!(await _authService.isAdmin)) {
      throw Exception(
        'Acesso negado: operação requer privilégios de administrador',
      );
    }
  }

  Future<void> _requireAuth() async {
    if (!_authService.isAuthenticated) {
      throw Exception('Acesso negado: usuário deve estar autenticado');
    }
  }

  // For now the user has no access to full CRUD operations in the cloud. (Read-only)
  // ===== CREATE =====
  /// Creates a new public cipher (admin only - not exposed to users)
  Future<String> createPublicCipher(Cipher cipher) async {
    await _requireAdmin();

    final firebaseId = await _firestoreService.createDocument(
      collectionPath: 'publicCiphers',
      data: cipher.toMap(),
    );

    // Create initial versions in sub-collection
    for (Version version in cipher.versions) {
      await _firestoreService.createSubCollectionDocument(
        parentCollectionPath: 'publicCiphers',
        parentDocumentId: firebaseId,
        subCollectionPath: 'versions',
        data: version.toMap(),
      );
    }
    return firebaseId;
  }

  /// Creates a new version for an existing public cipher (admin only)
  Future<String> createVersionForCipher(
    String cipherId,
    Version version,
  ) async {
    await _requireAdmin();

    final versionId = await _firestoreService.createSubCollectionDocument(
      parentCollectionPath: 'publicCiphers',
      parentDocumentId: cipherId,
      subCollectionPath: 'versions',
      data: version.toMap(),
    );
    return versionId;
  }

  // ===== READ =====
  /// Fetch popular ciphers from Firestore (requires authentication)
  Future<List<CipherDto>> getPopularCiphers() async {
    await _requireAuth();

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

  /// Fetch versions of a specific cipher (requires authentication)
  Future<List<VersionDto>> getVersionsOfCipher(String cipherId) async {
    await _requireAuth();

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

  /// Cost-effective single query search (requires authentication)
  Future<List<CipherDto>?> searchCiphers(String query) async {
    await _requireAuth();

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

  /// Download complete cipher (metadata + versions) by ID (requires authentication)
  Future<Cipher?> downloadCompleteCipher(String firebaseId) async {
    await _requireAuth();

    final cipherSnapshot = await _firestoreService.fetchDocumentById(
      collectionPath: 'publicCiphers',
      documentId: firebaseId,
    );

    final versionSnapshots = await _firestoreService
        .fetchSubCollectionDocuments(
          parentCollectionPath: 'publicCiphers',
          parentDocumentId: firebaseId,
          subCollectionPath: 'versions',
        );

    if (cipherSnapshot == null) {
      throw Exception('Cipher not found');
    }

    await FirebaseAnalytics.instance.logEvent(
      name: 'cipher_downloaded',
      parameters: {
        'cipher_id': firebaseId,
        'user_id': _authService.currentUser!.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    if (kDebugMode) {
      print('Downloaded cipher with ${versionSnapshots.length} versions');
    }

    final cipher = CipherDto.fromMap(
      cipherSnapshot.data() as Map<String, dynamic>,
    ).toDomain();

    for (var versionDoc in versionSnapshots) {
      final version = VersionDto.fromMap(
        versionDoc.data() as Map<String, dynamic>,
      ).toDomain(-1);
      cipher.versions.add(version);
    }

    return cipher;
  }

  // ===== UPDATE =====
  /// Update an existing public cipher (admin only)
  Future<void> updatePublicCipher(
    String cipherId,
    Map<String, dynamic> data,
  ) async {
    await _requireAdmin();

    await _firestoreService.updateDocument(
      collectionPath: 'publicCiphers',
      documentId: cipherId,
      data: data,
    );
  }

  /// Update an existing version of a public cipher (admin only)
  Future<void> updateVersionOfCipher(
    String cipherId,
    String versionId,
    Map<String, dynamic> data,
  ) async {
    await _requireAdmin();

    await _firestoreService.updateSubCollectionDocument(
      parentCollectionPath: 'publicCiphers',
      parentDocumentId: cipherId,
      subCollectionPath: 'versions',
      documentId: versionId,
      data: data,
    );
  }

  // ===== DELETE =====
  /// Delete a public cipher (admin only)
  Future<void> deletePublicCipher(String cipherId) async {
    await _requireAdmin();

    await _firestoreService.deleteDocument(
      collectionPath: 'publicCiphers',
      documentId: cipherId,
    );
  }

  /// Delete a version of a public cipher (admin only)
  Future<void> deleteVersionOfCipher(String cipherId, String versionId) async {
    await _requireAdmin();

    await _firestoreService.deleteSubCollectionDocument(
      parentCollectionPath: 'publicCiphers',
      parentDocumentId: cipherId,
      subCollectionPath: 'versions',
      documentId: versionId,
    );
  }
}
