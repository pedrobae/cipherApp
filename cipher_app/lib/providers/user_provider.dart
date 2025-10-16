import 'dart:async';
import 'package:cipher_app/models/domain/user.dart';
import 'package:cipher_app/repositories/local_user_repository.dart';
import 'package:cipher_app/repositories/cloud_user_repository.dart';
import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final CloudUserRepository _cloudUserRepository = CloudUserRepository();

  UserProvider();

  List<User> _knownCollaborators = [];
  List<User> _searchResults = [];
  String? _error;
  bool _hasInitialized = false;
  bool _isLoading = false;
  bool _isLoadingCloud = false;

  // Getters
  List<User> get knownCollaborators => _knownCollaborators;
  List<User> get searchResults => _searchResults;
  String? get error => _error;
  bool get hasInitialized => _hasInitialized;
  bool get isLoading => _isLoading;
  bool get isLoadingCloud => _isLoadingCloud;

  /// Removes all known users from a list of Firebase IDs
  /// This is used to resolve collaborator references in playlists
  List<String> removeKnownByFirebaseId(List<String> firebaseUserIds) {
    return firebaseUserIds
        .where((id) => _knownCollaborators.any((user) => user.firebaseId == id))
        .toList();
  }

  /// Downloads users from Firebase if they don't exist locally
  Future<void> downloadUsersFromCloud(List<String> firebaseUserIds) async {
    if (_isLoadingCloud) return;

    _isLoadingCloud = true;
    _error = null;
    notifyListeners();

    try {
      for (var userId in firebaseUserIds) {
        final userDto = await _cloudUserRepository.fetchUserById(userId);
        if (userDto != null) {
          final user = userDto.toDomain();
          await _userRepository.createUser(user);
          _knownCollaborators.add(user);
        } else {
          if (kDebugMode) {
            print('User with Firebase ID $userId not found in cloud.');
          }
          throw Exception('User with Firebase ID $userId not found in cloud.');
        }
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error downloading users from cloud: $e');
      }
    } finally {
      _isLoadingCloud = false;
      notifyListeners();
    }
  }

  /// Ensures that all users in the provided list of Firebase IDs exist locally
  /// Downloads any missing users from the cloud
  Future<void> ensureUsersExist(List<String> firebaseUserIds) async {
    final missingIds = removeKnownByFirebaseId(firebaseUserIds);
    if (missingIds.isNotEmpty) {
      await downloadUsersFromCloud(missingIds);
    }
  }

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
