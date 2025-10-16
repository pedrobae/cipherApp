import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cipher_app/services/firebase_service.dart';

/// Generic Firestore service for database operations.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseService().firestore;

  /// Create a new document in a specified collection, with auto-generated ID.
  Future<String> createDocument({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      final docRef = await _firestore.collection(collectionPath).add(data);
      return docRef.id;
    } catch (e) {
      FirebaseService.logError('Failed to create document', e);
      rethrow;
    }
  }

  /// Create a new document in a specified subcollection, with auto-generated ID.
  Future<String> createSubCollectionDocument({
    required String parentCollectionPath,
    required String parentDocumentId,
    required String subCollectionPath,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      final docRef = await _firestore
          .collection(parentCollectionPath)
          .doc(parentDocumentId)
          .collection(subCollectionPath)
          .add(data);
      return docRef.id;
    } catch (e) {
      FirebaseService.logError('Failed to create sub-collection document', e);
      rethrow;
    }
  }

  /// Fetch documents from a specified collection with optional query parameters.
  Future<List<QueryDocumentSnapshot>> fetchDocuments({
    required String collectionPath,
    Map<String, dynamic>? filters,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore.collection(collectionPath).limit(limit);

      // Apply filters if provided
      filters?.forEach((field, value) {
        query = query.where(field, isEqualTo: value);
      });

      final querySnapshot = await query.get();
      return querySnapshot.docs;
    } catch (e) {
      FirebaseService.logError('Failed to fetch documents', e);
      rethrow;
    }
  }

  /// Fetch all documents from a specified sub-collection.
  Future<List<QueryDocumentSnapshot>> fetchSubCollectionDocuments({
    required String parentCollectionPath,
    required String parentDocumentId,
    required String subCollectionPath,
    int limit = 50,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(parentCollectionPath)
          .doc(parentDocumentId)
          .collection(subCollectionPath)
          .limit(limit)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      FirebaseService.logError('Failed to fetch sub-collection documents', e);
      rethrow;
    }
  }

  /// Fetch a single document by ID from a specified collection.
  Future<DocumentSnapshot?> fetchDocumentById({
    required String collectionPath,
    required String documentId,
  }) async {
    try {
      final docSnapshot = await _firestore
          .collection(collectionPath)
          .doc(documentId)
          .get();
      return docSnapshot.exists ? docSnapshot : null;
    } catch (e) {
      FirebaseService.logError('Failed to fetch document by ID', e);
      rethrow;
    }
  }

  /// Fetch a single document by ID from a specified sub-collection.
  Future<DocumentSnapshot?> fetchSubCollectionDocumentById({
    required String parentCollectionPath,
    required String parentDocumentId,
    required String subCollectionPath,
    required String documentId,
  }) async {
    try {
      final docSnapshot = await _firestore
          .collection(parentCollectionPath)
          .doc(parentDocumentId)
          .collection(subCollectionPath)
          .doc(documentId)
          .get();
      return docSnapshot.exists ? docSnapshot : null;
    } catch (e) {
      FirebaseService.logError(
        'Failed to fetch sub-collection document by ID',
        e,
      );
      rethrow;
    }
  }

  /// Update a document in a specified collection.
  Future<void> updateDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore
          .collection(collectionPath)
          .doc(documentId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      FirebaseService.logError('Failed to set document', e);
      rethrow;
    }
  }

  /// Update a document in a specified sub-collection.
  Future<void> updateSubCollectionDocument({
    required String parentCollectionPath,
    required String parentDocumentId,
    required String subCollectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore
          .collection(parentCollectionPath)
          .doc(parentDocumentId)
          .collection(subCollectionPath)
          .doc(documentId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      FirebaseService.logError('Failed to update sub-collection document', e);
      rethrow;
    }
  }

  /// Delete a document from a specified collection.
  Future<void> deleteDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).delete();
    } catch (e) {
      FirebaseService.logError('Failed to delete document', e);
      rethrow;
    }
  }

  Future<void> deleteSubCollectionDocument({
    required String parentCollectionPath,
    required String parentDocumentId,
    required String subCollectionPath,
    required String documentId,
  }) async {
    try {
      await _firestore
          .collection(parentCollectionPath)
          .doc(parentDocumentId)
          .collection(subCollectionPath)
          .doc(documentId)
          .delete();
    } catch (e) {
      FirebaseService.logError('Failed to delete sub-collection document', e);
      rethrow;
    }
  }

  // ===== SEARCH METHODS =====

  /// Buscar documentos usando tokens de pesquisa em múltiplos campos
  Future<List<QueryDocumentSnapshot>> fetchDocumentsBySearchTokens({
    required String collectionPath,
    required String searchTerm,
    Map<String, dynamic>? exactFilters,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore.collection(collectionPath).limit(limit);

      // Aplicar filtros exatos primeiro
      exactFilters?.forEach((field, value) {
        query = query.where(field, isEqualTo: value);
      });

      // Buscar por tokens de pesquisa (inclui title, author, tags)
      if (searchTerm.isNotEmpty) {
        final searchTokens = _generateSearchTokens(searchTerm);
        if (searchTokens.isNotEmpty) {
          // Firestore permite apenas um array-contains por query
          query = query.where(
            'searchTokens',
            arrayContains: searchTokens.first,
          );
        }
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs;
    } catch (e) {
      FirebaseService.logError('Falha ao buscar documentos por tokens', e);
      rethrow;
    }
  }

  /// Buscar documentos por prefixo de texto (para autocompletar)
  Future<List<QueryDocumentSnapshot>> fetchDocumentsByPrefix({
    required String collectionPath,
    required String fieldName,
    required String prefix,
    Map<String, dynamic>? exactFilters,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore.collection(collectionPath).limit(limit);

      // Aplicar filtros exatos primeiro
      exactFilters?.forEach((field, value) {
        query = query.where(field, isEqualTo: value);
      });

      // Busca por prefixo (use campos em minúsculas como 'titleLower', 'authorLower')
      if (prefix.isNotEmpty) {
        final prefixLower = prefix.toLowerCase();
        query = query
            .where(fieldName, isGreaterThanOrEqualTo: prefixLower)
            .where(fieldName, isLessThan: '${prefixLower}z');
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs;
    } catch (e) {
      FirebaseService.logError('Falha ao buscar documentos por prefixo', e);
      rethrow;
    }
  }

  /// Buscar documentos com múltiplos campos de texto simultaneamente
  Future<List<QueryDocumentSnapshot>> fetchDocumentsMultiFieldSearch({
    required String collectionPath,
    required String searchTerm,
    Map<String, dynamic>? exactFilters,
    int limit = 20,
  }) async {
    try {
      final searchLower = searchTerm.toLowerCase().trim();
      Set<String> allResults = {};
      List<QueryDocumentSnapshot> combinedResults = [];

      // 1. Busca por tokens (mais abrangente - inclui title, author, tags)
      final tokenResults = await fetchDocumentsBySearchTokens(
        collectionPath: collectionPath,
        searchTerm: searchLower,
        exactFilters: exactFilters,
        limit: limit,
      );

      for (var doc in tokenResults) {
        if (!allResults.contains(doc.id)) {
          allResults.add(doc.id);
          combinedResults.add(doc);
        }
      }

      // 2. Se não encontrou suficientes, busca por prefixo em título
      if (combinedResults.length < 10) {
        final titleResults = await fetchDocumentsByPrefix(
          collectionPath: collectionPath,
          fieldName: 'titleLower',
          prefix: searchLower,
          exactFilters: exactFilters,
          limit: 10,
        );

        for (var doc in titleResults) {
          if (!allResults.contains(doc.id)) {
            allResults.add(doc.id);
            combinedResults.add(doc);
          }
        }
      }

      // 3. Se ainda não encontrou suficientes, busca por prefixo em autor
      if (combinedResults.length < 10) {
        final authorResults = await fetchDocumentsByPrefix(
          collectionPath: collectionPath,
          fieldName: 'authorLower',
          prefix: searchLower,
          exactFilters: exactFilters,
          limit: 10,
        );

        for (var doc in authorResults) {
          if (!allResults.contains(doc.id)) {
            allResults.add(doc.id);
            combinedResults.add(doc);
          }
        }
      }

      return combinedResults.take(limit).toList();
    } catch (e) {
      FirebaseService.logError('Falha na busca multi-campo', e);
      rethrow;
    }
  }

  /// Buscar documentos com estratégia em cascata (múltiplas tentativas)
  Future<List<QueryDocumentSnapshot>> fetchDocumentsWithCascadingSearch({
    required String collectionPath,
    required String searchTerm,
    Map<String, dynamic>? exactFilters,
    int limit = 25,
  }) async {
    try {
      final searchLower = searchTerm.toLowerCase().trim();
      Set<String> processedIds = {};
      List<QueryDocumentSnapshot> results = [];

      // Gerar variações da busca para máxima cobertura
      final searchVariations = _generateSearchVariations(searchLower);

      // Buscar por cada variação até encontrar resultados suficientes
      for (String variation in searchVariations.take(3)) {
        if (results.length >= limit) break;

        try {
          final variationResults = await fetchDocumentsBySearchTokens(
            collectionPath: collectionPath,
            searchTerm: variation,
            exactFilters: exactFilters,
            limit: 15,
          );

          for (var doc in variationResults) {
            if (!processedIds.contains(doc.id) && results.length < limit) {
              processedIds.add(doc.id);
              results.add(doc);
            }
          }
        } catch (e) {
          // Continue para próxima variação se esta falhar
          continue;
        }
      }

      return results;
    } catch (e) {
      FirebaseService.logError('Falha na busca em cascata', e);
      rethrow;
    }
  }

  Future<List<QueryDocumentSnapshot>> fetchDocumentsContainingValue({
    required String collectionPath,
    required String field,
    required dynamic value,
    int limit = 50,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionPath)
          .where(field, arrayContains: value)
          .limit(limit)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      FirebaseService.logError('Failed to query collection', e);
      rethrow;
    }
  }

  // ===== HELPER METHODS =====

  /// Gerar tokens de pesquisa a partir de um termo
  List<String> _generateSearchTokens(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove pontuação
        .split(' ')
        .where((token) => token.length >= 2) // Tokens mínimos de 2 caracteres
        .toList();
  }

  /// Gerar variações de busca para cobertura máxima
  List<String> _generateSearchVariations(String query) {
    List<String> variations = [query];

    // Adiciona palavras individuais
    final words = query.split(' ').where((w) => w.length >= 3);
    variations.addAll(words);

    // Adiciona prefixos de palavras (para busca parcial)
    for (String word in words) {
      if (word.length >= 4) {
        variations.add(word.substring(0, word.length - 1));
      }
      if (word.length >= 5) {
        variations.add(word.substring(0, word.length - 2));
      }
    }

    return variations.toSet().toList(); // Remove duplicatas
  }
}
