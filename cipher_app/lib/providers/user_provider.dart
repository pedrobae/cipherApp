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
