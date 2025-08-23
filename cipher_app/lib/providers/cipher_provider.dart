import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/domain/cipher.dart';
import '../services/cipher_service.dart';
import '../repositories/cipher_repository.dart';

class CipherProvider extends ChangeNotifier {
  // static const int _memoryThreshold = 10000; // Higher threshold for local DB
  
  final CipherRepository _cipherRepository = CipherRepository();
  
  List<Cipher> _ciphers = [];
  List<Cipher> _filteredCiphers = [];
  bool _isLoading = false;
  String? _error;
  String _searchTerm = '';
  bool _useMemoryFiltering = true;

  // Add debouncing for rapid calls
  Timer? _loadTimer;

  // Getters
  List<Cipher> get ciphers => _filteredCiphers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get useMemoryFiltering => _useMemoryFiltering;

  // Load ciphers from local SQLite database
  Future<void> loadCiphers() async {
    // Debounce rapid calls
    _loadTimer?.cancel();
    _loadTimer = Timer(const Duration(milliseconds: 100), _performLoad);
  }

  Future<void> _performLoad() async {
    if (_isLoading) return; // Prevent multiple simultaneous loads

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load all ciphers from SQLite (they're local, so should be fast)
      _useMemoryFiltering = true;
      _ciphers = await _cipherRepository.getAllCiphers();
      _filterCiphers();
      
      if (kDebugMode) {
        print('Loaded ${_ciphers.length} ciphers from SQLite');
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

  // Future<void> _loadCiphersInChunks() async {
  //   final allCiphers = await CipherService.getAllCiphers();
    
  //   // Process in smaller chunks to prevent frame drops
  //   const chunkSize = 10;
  //   _ciphers.clear();
    
  //   for (int i = 0; i < allCiphers.length; i += chunkSize) {
  //     final chunk = allCiphers.skip(i).take(chunkSize).toList();
  //     _ciphers.addAll(chunk);
      
  //     // Yield control back to UI thread
  //     await Future.delayed(const Duration(milliseconds: 1));
  //   }
    
  //   _filterCiphers();
  // }

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
        _filteredCiphers = await _cipherRepository.getAllCiphers();
      } else {
        // SQLite search with repository
        _filteredCiphers = await _cipherRepository.searchCiphers(term);
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
    _loadTimer?.cancel();
    // Close database connection when ready
    CipherService.closeDatabase(); // Add this when you implement the service
    
    // Clear any listeners or subscriptions if added later
    // _searchDebounceTimer?.cancel(); // If you add debouncing
    
    super.dispose();
  }
}