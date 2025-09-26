import 'package:cipher_app/services/firestore_service.dart';
import 'package:cipher_app/models/domain/cipher/cipher.dart';
import 'package:cipher_app/models/dtos/cipher_dto.dart';

class CloudCipherRepository {
  final FirestoreService _firestoreService = FirestoreService();

  // For now the user has no access to writing ciphers to the cloud. (Read-only)

  /// ===== READ =====
  /// Fetch popular ciphers from Firestore
  Future<List<Cipher>> getPopularCiphers() async {
    final snapshot = await _firestoreService.fetchDocumentById(
      collectionPath: 'stats/',
      documentId: 'popularCiphers',
    );

    List<Cipher> ciphers =
        ((snapshot!.data() as Map<String, dynamic>)['ciphers'] as List)
            .map<Cipher>((map) => CipherDto.fromMap(map).toDomain())
            .toList();

    return ciphers;
  }
}
