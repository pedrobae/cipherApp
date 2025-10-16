import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/domain/user.dart';
import '../repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  UserProvider();

  List<User> _knownCollaborators = [];
  List<User> _searchResults = [];
  String? _error;
  bool _hasInitialized = false;
  bool _isLoading = false;

  // Getters
  List<User> get knownCollaborators => _knownCollaborators;
  List<User> get searchResults => _searchResults;
  String? get error => _error;
  bool get hasInitialized => _hasInitialized;

  // TODO: PLAYLIST CLOUD SYNC - Add method to check if user exists by Firebase userId
  // This is needed for PlaylistProvider._mergePlaylistFromCloud() to verify
  // if collaborators referenced in cloud playlists exist locally.
  //
  // Suggested implementation:
  // User? getUserByFirebaseId(String firebaseUserId) {
  //   try {
  //     return _knownCollaborators.firstWhere(
  //       (user) => user.firebaseId == firebaseUserId,
  //     );
  //   } catch (_) {
  //     return null;
  //   }
  // }

  // TODO: PLAYLIST CLOUD SYNC - Add method to download missing users from Firebase
  // When a cloud playlist references a collaborator that doesn't exist locally,
  // this method should download their profile from Firebase and save to local SQLite.
  //
  // Suggested implementation:
  // Future<User?> downloadUserFromCloud(String firebaseUserId) async {
  //   final userDto = await _cloudUserRepository.fetchUserById(firebaseUserId);
  //   if (userDto != null) {
  //     final user = userDto.toDomain();
  //     await _userRepository.insertUser(user);
  //     _knownCollaborators.add(user);
  //     notifyListeners();
  //     return user;
  //   }
  //   return null;
  // }

  // TODO: PLAYLIST CLOUD SYNC - Add batch method to ensure multiple users exist
  // Efficiently check and download a list of users referenced in a playlist.
  //
  // Suggested implementation:
  // Future<void> ensureUsersExist(List<String> firebaseUserIds) async {
  //   for (var userId in firebaseUserIds) {
  //     final exists = getUserByFirebaseId(userId) != null;
  //     if (!exists) {
  //       await downloadUserFromCloud(userId);
  //     }
  //   }
  // }

  // Load users from local SQLite db
  Future<void> loadUsers() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _knownCollaborators = await _userRepository.getAllUsers();
      _hasInitialized = true;

      if (kDebugMode) {
        print('Loaded ${_knownCollaborators.length} Users from SQLite');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading ciphers: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search users
  void searchUsers(String value) async {
    String searchValue = value.toLowerCase();
    if (searchValue.isEmpty) {
      _searchResults = _knownCollaborators;
    } else {
      _searchResults = _knownCollaborators
          .where(
            (user) =>
                user.username.toLowerCase().contains(searchValue) ||
                user.mail.toLowerCase().contains(searchValue),
          )
          .toList();
    }
    notifyListeners();
  }

  // Clears search users
  void clearSearchResults() async {
    _searchResults = _knownCollaborators;
  }
}
