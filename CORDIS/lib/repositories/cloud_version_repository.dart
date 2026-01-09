import 'package:cordis/helpers/guard.dart';
import 'package:cordis/models/dtos/version_dto.dart';
import 'package:cordis/services/firestore_service.dart';
import 'package:cordis/services/auth_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class CloudVersionRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final GuardHelper _guardHelper = GuardHelper();

  // ================== VERSION METHODS ==================

  // ===== CREATE =====
  /// Publishes a new version of a public cipher (admin only)
  Future<String> publishPublicVersion(VersionDto version) async {
    await _guardHelper.requireAdmin();

    final docId = await _firestoreService.createDocument(
      collectionPath: 'publicVersions',
      data: version.toFirestore(),
    );

    FirebaseAnalytics.instance.logEvent(
      name: 'published_public_version',
      parameters: {
        'version_id': docId,
        'user_id': _authService.currentUser!.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    return docId;
  }

  /// Publishes a new version of a cipher in the user's personal collection (requires authentication)
  Future<String> publishPersonalVersion(VersionDto version) async {
    await _guardHelper.requireAuth();

    final docId = await _firestoreService.createSubCollectionDocument(
      parentCollectionPath: 'users/',
      parentDocumentId: _authService.currentUser!.uid,
      subCollectionPath: 'versions',
      data: version.toFirestore(),
    );

    FirebaseAnalytics.instance.logEvent(
      name: 'published_personal_version',
      parameters: {
        'version_id': docId,
        'user_id': _authService.currentUser!.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    return docId;
  }

  // ===== READ =====
  /// Fetch public versions (requires authentication)
  Future<List<VersionDto>> getPublicVersions() async {
    await _guardHelper.requireAuth();

    final snapshot = await _firestoreService.fetchDocuments(
      collectionPath: 'publicVersions',
    );

    FirebaseAnalytics.instance.logEvent(
      name: 'fetched_public_versions',
      parameters: {
        'version_count': snapshot.length,
        'user_id': _authService.currentUser!.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    return snapshot
        .map(
          (version) => VersionDto.fromFirestore(
            version.data() as Map<String, dynamic>,
            version.id,
          ),
        )
        .toList();
  }

  /// Fetch personal versions of the current user (requires authentication)
  Future<List<VersionDto>> getPersonalVersions() async {
    await _guardHelper.requireAuth();

    final snapshot = await _firestoreService.fetchSubCollectionDocuments(
      parentCollectionPath: 'users/',
      parentDocumentId: _authService.currentUser!.uid,
      subCollectionPath: 'versions',
    );

    FirebaseAnalytics.instance.logEvent(
      name: 'fetched_personal_versions',
      parameters: {
        'version_count': snapshot.length,
        'user_id': _authService.currentUser!.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    return snapshot
        .map(
          (version) => VersionDto.fromFirestore(
            version.data() as Map<String, dynamic>,
            version.id,
          ),
        )
        .toList();
  }

  // ===== UPDATE =====
  /// Update a public version (admin only)
  Future<void> updatePublicVersion(VersionDto version) async {
    await _guardHelper.requireAdmin();

    await _firestoreService.updateDocument(
      collectionPath: 'publicVersions',
      documentId: version.firebaseId!,
      data: version.toFirestore(),
    );

    FirebaseAnalytics.instance.logEvent(
      name: 'public_version_updated',
      parameters: {
        'version_id': version.firebaseId!,
        'user_id': _authService.currentUser!.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Update a personal version (requires authentication)
  Future<void> updatePersonalVersion(VersionDto version) async {
    await _guardHelper.requireAuth();

    await _firestoreService.updateSubCollectionDocument(
      parentCollectionPath: 'users/',
      parentDocumentId: _authService.currentUser!.uid,
      subCollectionPath: 'versions',
      documentId: version.firebaseId!,
      data: version.toFirestore(),
    );

    FirebaseAnalytics.instance.logEvent(
      name: 'personal_version_updated',
      parameters: {
        'version_id': version.firebaseId!,
        'user_id': _authService.currentUser!.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ===== DELETE =====
  /// Delete a version of a public cipher (admin only)
  Future<void> deletePublicVersion(String versionId) async {
    await _guardHelper.requireAdmin();

    await _firestoreService.deleteDocument(
      collectionPath: 'publicVersions',
      documentId: versionId,
    );

    FirebaseAnalytics.instance.logEvent(
      name: 'public_version_deleted',
      parameters: {
        'version_id': versionId,
        'user_id': _authService.currentUser!.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
}
