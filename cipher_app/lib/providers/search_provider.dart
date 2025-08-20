import 'package:flutter/foundation.dart';

class SearchProvider extends ChangeNotifier {
  String _searchTerm = '';

  String get searchTerm => _searchTerm;

  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  void clearSearch() {
    _searchTerm = '';
    notifyListeners();
  }
}
