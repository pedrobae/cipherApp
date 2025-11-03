import 'package:cipher_app/helpers/guard.dart';
import 'package:cipher_app/models/domain/cipher/cipher.dart';
import 'package:cipher_app/models/domain/cipher/version.dart';
import 'package:cipher_app/models/dtos/cipher_dto.dart';
import 'package:cipher_app/models/dtos/version_dto.dart';
import 'package:cipher_app/services/firestore_service.dart';
import 'package:cipher_app/services/auth_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class CloudCipherRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final GuardHelper _guardHelper = GuardHelper();

  // ===== READ =====
  /// Fetch popular ciphers from Firestore (requires authentication)
  Future<List<CipherDto>> getCipherIndex() async {
    await _guardHelper.requireAuth();

    final snapshot = await _firestoreService.fetchDocumentById(
      collectionPath: 'indexes/',
      documentId: 'publicCiphers',
    );

    FirebaseAnalytics.instance.logEvent(
      name: 'fetched_cipher_index',
      parameters: {
        'user_id': _authService.currentUser!.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    List<CipherDto> ciphers =
        ((snapshot!.data() as Map<String, dynamic>)['ciphers'] as List)
            .map<CipherDto>(
              (map) =>
                  CipherDto.fromFirestore(map, map['firebaseId'] as String),
            )
            .toList();

    return ciphers;
  }

  /// Fetch versions of a specific cipher (requires authentication)
  Future<List<VersionDto>> getVersionsOfCipher(String cipherId) async {
    await _guardHelper.requireAuth();

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
          (version) => VersionDto.fromFirestore(
            version.data() as Map<String, dynamic>,
            id: version.id,
            cipherId: cipherId,
          ),
        )
        .toList();
  }

  // ===== UPDATE =====
  /// Update an existing public cipher (admin only)
  Future<void> updatePublicCipher(Cipher cipher) async {
    await _guardHelper.requireAdmin();

    await _firestoreService.updateDocument(
      collectionPath: 'publicCiphers',
      documentId: cipher.firebaseId!,
      data: cipher.toDto().toFirestore(),
    );

    FirebaseAnalytics.instance.logEvent(
      name: 'cipher_updated',
      parameters: {
        'cipher_id': cipher.firebaseId!,
        'user_id': _authService.currentUser!.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Update an existing version of a public cipher (admin only)
  Future<void> updateVersionOfCipher(Version version) async {
    await _guardHelper.requireAdmin();

    await _firestoreService.updateSubCollectionDocument(
      parentCollectionPath: 'publicCiphers',
      parentDocumentId: version.firebaseCipherId!,
      subCollectionPath: 'versions',
      documentId: version.firebaseId!,
      data: version.toDto().toFirestore(),
    );

    FirebaseAnalytics.instance.logEvent(
      name: 'cipher_version_updated',
      parameters: {
        'cipher_id': version.firebaseCipherId!,
        'version_id': version.firebaseId!,
        'user_id': _authService.currentUser!.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ===== DELETE =====
  /// Delete a public cipher (admin only)
  Future<void> deletePublicCipher(String cipherId) async {
    await _guardHelper.requireAdmin();

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
    await _guardHelper.requireAdmin();

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
