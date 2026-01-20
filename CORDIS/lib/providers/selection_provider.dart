import 'package:flutter/foundation.dart';

class SelectionProvider extends ChangeNotifier {
  bool _isSelectionMode = false;
  int? _targetId; // Playlist ID
  final List<dynamic> _selectedItems = [];

  bool get isSelectionMode => _isSelectionMode;
  List<dynamic> get selectedItems => _selectedItems;
  int? get targetId => _targetId;

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

  void setTarget(int id) {
    _targetId = id;
  }

  bool isItemSelected(dynamic item) {
    return _selectedItems.contains(item);
  }
}
