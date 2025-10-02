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
      data['lastUpdated'] = FieldValue.serverTimestamp();
      data['searchText'] =
          '${data['title'] as String? ?? ''} ${data['author'] as String? ?? ''} ${(data['tags'] as List<dynamic>?)?.map((tag) => tag.toString()).join(' ') ?? ''}';
      final docRef = await _firestore.collection(collectionPath).add(data);
      return docRef.id;
    } catch (e) {
      FirebaseService.logError('Failed to create document', e);
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

  /// Update a document in a specified collection.
  Future<void> updateDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(documentId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      FirebaseService.logError('Failed to set document', e);
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
}
