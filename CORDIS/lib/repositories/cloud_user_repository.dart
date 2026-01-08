import 'package:cordis/models/dtos/user_dto.dart';
import 'package:cordis/services/firestore_service.dart';

class CloudUserRepository {
  final FirestoreService _firestoreService = FirestoreService();

  CloudUserRepository();

  /// Fetches a user by their Firebase ID from Firestore
  Future<UserDto?> fetchUserById(String userId) async {
    final docSnapshot = await _firestoreService.fetchDocumentById(
      collectionPath: 'users',
      documentId: userId,
    );

    if (docSnapshot == null || !docSnapshot.exists) {
      return null;
    }

    return UserDto.fromFirestore(
      docSnapshot.data() as Map<String, dynamic>,
      docSnapshot.id,
    );
  }

  /// Creates or updates a user profile in Firestore
  /// IMPORTANT: Uses Firebase Auth UID as the document ID
  Future<void> createOrUpdateUser(UserDto userDto) async {
    if (userDto.firebaseId == null) {
      throw ArgumentError('UserDto must have a firebaseId (Firebase Auth UID)');
    }

    await _firestoreService.updateDocument(
      collectionPath: 'users',
      documentId: userDto.firebaseId!,
      data: userDto.toFirestore(),
    );
  }

  /// Searches for users by username (for adding collaborators)
  Future<List<UserDto>> searchUsersByUsername(String query) async {
    final docs = await _firestoreService.fetchDocuments(
      collectionPath: 'users',
      filters: {'username': query},
      limit: 10,
    );

    return docs
        .map(
          (doc) =>
              UserDto.fromFirestore(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }
}
