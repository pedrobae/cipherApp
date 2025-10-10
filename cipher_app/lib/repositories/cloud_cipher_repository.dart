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

    final cipherId = await _firestoreService.createDocument(
      collectionPath: 'publicCiphers',
      data: cipher.toDto().toFirestore(),
    );

    FirebaseAnalytics.instance.logEvent(
      name: 'cipher_created',
      parameters: {
        'cipher_id': cipherId,
        'user_id': _authService.currentUser!.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    // Create initial versions in sub-collection
    for (Version version in cipher.versions) {
      final versionId = await _firestoreService.createSubCollectionDocument(
        parentCollectionPath: 'publicCiphers',
        parentDocumentId: cipherId,
        subCollectionPath: 'versions',
        data: version.toDto().toFirestore(),
      );

      FirebaseAnalytics.instance.logEvent(
        name: 'cipher_version_created',
        parameters: {
          'cipher_id': cipherId,
          'version_id': versionId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    }
    return cipherId;
  }

  /// Creates a new version for an existing public cipher (admin only)
  Future<String> createVersionForCipher(
    String cipherId,
    VersionDto version,
  ) async {
    await _requireAdmin();

    final versionId = await _firestoreService.createSubCollectionDocument(
      parentCollectionPath: 'publicCiphers',
      parentDocumentId: cipherId,
      subCollectionPath: 'versions',
      data: version.toFirestore(),
    );

    FirebaseAnalytics.instance.logEvent(
      name: 'cipher_version_created',
      parameters: {
        'cipher_id': cipherId,
        'version_id': versionId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
    return versionId;
  }

  Future<String> createPublicCipherFromJson(Map<String, dynamic> json) async {
    final versions = json.remove('versions');
    final cipherId = await _firestoreService.createDocument(
      collectionPath: 'publicCiphers',
      data: json,
    );

    FirebaseAnalytics.instance.logEvent(
      name: 'cipher_created',
      parameters: {
        'cipher_id': cipherId,
        'user_id': _authService.currentUser!.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    // Create initial versions in sub-collection
    for (var version in versions) {
      final versionId = await _firestoreService.createSubCollectionDocument(
        parentCollectionPath: 'publicCiphers',
        parentDocumentId: cipherId,
        subCollectionPath: 'versions',
        data: version as Map<String, dynamic>,
      );

      FirebaseAnalytics.instance.logEvent(
        name: 'cipher_version_created',
        parameters: {
          'cipher_id': cipherId,
          'version_id': versionId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    }
    return cipherId;
  }

  // ===== READ =====
  /// Fetch popular ciphers from Firestore (requires authentication)
  Future<List<CipherDto>> getPopularCiphers() async {
    await _requireAuth();

    final snapshot = await _firestoreService.fetchDocumentById(
      collectionPath: 'stats/',
      documentId: 'popularCiphers',
    );

    FirebaseAnalytics.instance.logEvent(
      name: 'fetched_popular_ciphers',
      parameters: {
        'user_id': _authService.currentUser!.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    List<CipherDto> ciphers =
        ((snapshot!.data() as Map<String, dynamic>)['ciphers'] as List)
            .map<CipherDto>((map) => CipherDto.fromFirestore(map))
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

    FirebaseAnalytics.instance.logEvent(
      name: 'fetched_cipher_versions',
      parameters: {
        'cipher_id': cipherId,
        'version_count': snapshot.length,
        'user_id': _authService.currentUser!.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    return snapshot
        .map(
          (version) =>
              VersionDto.fromFirestore(version.data() as Map<String, dynamic>),
        )
        .toList();
  }

  /// Multi field search (requires authentication)
  Future<List<CipherDto>?> searchCiphers(String query) async {
    await _requireAuth();

    try {
      // Single query approach - search in combined searchText field
      final results = await _firestoreService.fetchDocumentsMultiFieldSearch(
        collectionPath: 'publicCiphers',
        searchTerm: query,
      );

      FirebaseAnalytics.instance.logEvent(
        name: 'searched_ciphers',
        parameters: {
          'query': query,
          'result_count': results.length,
          'user_id': _authService.currentUser!.uid,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      return results.map((doc) {
        final map = doc.data() as Map<String, dynamic>;
        map['firebaseId'] = doc.id;
        return CipherDto.fromFirestore(map);
      }).toList();
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

      // 1. Search in title first
      final titleResults = await _firestoreService.fetchDocuments(
        collectionPath: 'publicCiphers',
        filters: {'titleLower': lowerQuery},
        limit: 25,
      );

      results.addAll(
        titleResults
            .map(
              (doc) =>
                  CipherDto.fromFirestore(doc.data() as Map<String, dynamic>),
            )
            .toList(),
      );

      // 2. If we have enough results from title, return early
      if (results.length >= 15) {
        return results.take(25).toList();
      }

      // 3. Search in author only if needed
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
            .map(
              (doc) =>
                  CipherDto.fromFirestore(doc.data() as Map<String, dynamic>),
            )
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
                (doc) =>
                    CipherDto.fromFirestore(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
      }

      FirebaseAnalytics.instance.logEvent(
        name: 'searched_ciphers_cascading',
        parameters: {
          'query': query,
          'result_count': results.length,
          'user_id': _authService.currentUser!.uid,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      return results.take(25).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching ciphers: $e');
      }
      return null;
    }
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

    FirebaseAnalytics.instance.logEvent(
      name: 'cipher_updated',
      parameters: {
        'cipher_id': cipherId,
        'user_id': _authService.currentUser!.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
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

    FirebaseAnalytics.instance.logEvent(
      name: 'cipher_version_updated',
      parameters: {
        'cipher_id': cipherId,
        'version_id': versionId,
        'user_id': _authService.currentUser!.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
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

    FirebaseAnalytics.instance.logEvent(
      name: 'cipher_deleted',
      parameters: {
        'cipher_id': cipherId,
        'user_id': _authService.currentUser!.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
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

    FirebaseAnalytics.instance.logEvent(
      name: 'cipher_version_deleted',
      parameters: {
        'cipher_id': cipherId,
        'version_id': versionId,
        'user_id': _authService.currentUser!.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
}
