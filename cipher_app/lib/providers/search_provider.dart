import 'package:flutter/foundation.dart';

class SearchProvider extends ChangeNotifier {
  String _searchTerm = '';
  bool _isSearching = false;

  String get searchTerm => _searchTerm;
  bool get isSearching => _isSearching;

  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  void toggleSearch() {
    _isSearching = !_isSearching;
    if (!_isSearching) {
      clearSearch();
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchTerm = '';
    notifyListeners();
  }
}
