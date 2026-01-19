import 'package:flutter/foundation.dart';

class SelectionProvider extends ChangeNotifier {
  bool _isSelectionMode = false;
  dynamic targetId; // Playlsit ID, could be String or int
  final List<dynamic> _selectedItems = [];

  bool get isSelectionMode => _isSelectionMode;
  List<dynamic> get selectedItems => _selectedItems;

  void enableSelectionMode() {
    _isSelectionMode = true;
    notifyListeners();
  }

  void disableSelectionMode() {
    _isSelectionMode = false;
    _selectedItems.clear();
    notifyListeners();
  }

  void toggleItemSelection(dynamic item) {
    if (_selectedItems.contains(item)) {
      _selectedItems.remove(item);
      if (_selectedItems.isEmpty) {
        disableSelectionMode();
      }
    } else {
      _selectedItems.add(item);
    }
    notifyListeners();
  }

  set target(dynamic id) {
    targetId = id;
  }

  bool isItemSelected(dynamic item) {
    return _selectedItems.contains(item);
  }
}
