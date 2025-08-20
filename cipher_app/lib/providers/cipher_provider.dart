import 'package:flutter/foundation.dart';
import '../models/domain/cipher.dart';
import '../services/cipher_service.dart';

class CipherProvider extends ChangeNotifier {
  static const int _memoryThreshold = 10000; // Higher threshold for local DB
  
  List<Cipher> _ciphers = [];
  List<Cipher> _filteredCiphers = [];
  bool _isLoading = false;
  String? _error;
  String _searchTerm = '';
  bool _useMemoryFiltering = true;

  // Getters
  List<Cipher> get ciphers => _filteredCiphers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get useMemoryFiltering => _useMemoryFiltering;

  // Load ciphers from local SQLite database
  Future<void> loadCiphers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check total count first
      final totalCount = await CipherService.getCipherCount();
      
      if (totalCount <= _memoryThreshold) {
        // Load all ciphers into memory for instant filtering
        _useMemoryFiltering = true;
        _ciphers = await CipherService.getAllCiphers();
        _filterCiphers();
        
        if (kDebugMode) {
          print('Loaded $totalCount ciphers into memory');
        }
      } else {
        // Use database filtering for large datasets
        _useMemoryFiltering = false;
        _filteredCiphers = await CipherService.getCiphers(limit: 100);
        
        if (kDebugMode) {
          print('Using database filtering for $totalCount ciphers');
        }
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

  // Search functionality
  Future<void> searchCiphers(String term) async {
    _searchTerm = term.toLowerCase();
    
    if (_useMemoryFiltering) {
      // Instant memory filtering
      _filterCiphers();
    } else {
      // SQLite query with debouncing
      await _searchInDatabase(term);
    }
  }

  void _filterCiphers() {
    if (_searchTerm.isEmpty) {
      _filteredCiphers = List.from(_ciphers);
    } else {
      _filteredCiphers = _ciphers
          .where((cipher) =>
              cipher.title.toLowerCase().contains(_searchTerm) ||
              cipher.author.toLowerCase().contains(_searchTerm))
          .toList();
    }
    notifyListeners();
  }

  Future<void> _searchInDatabase(String term) async {
    try {
      if (term.isEmpty) {
        _filteredCiphers = await CipherService.getCiphers(limit: 100);
      } else {
        // SQLite FTS (Full-Text Search) is very efficient for local queries
        _filteredCiphers = await CipherService.searchCiphers(term);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Add cipher to playlist
  Future<void> addToPlaylist(Cipher cipher, String playlistId) async {
    try {
      await CipherService.addToPlaylist(cipher.id, playlistId);
      // Update local state if needed
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadCiphers();
  }

  @override
  void dispose() {
    // Close database connection when ready
    CipherService.closeDatabase(); // Add this when you implement the service
    
    // Clear any listeners or subscriptions if added later
    // _searchDebounceTimer?.cancel(); // If you add debouncing
    
    super.dispose();
  }
}