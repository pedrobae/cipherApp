import 'package:cordis/repositories/local_playlist_repository.dart';
import 'package:flutter/foundation.dart';

class SelectionProvider extends ChangeNotifier {
  PlaylistRepository playlistRepository = PlaylistRepository();

  bool _isSelectionMode = false;
  int? _targetId; // Playlist ID
  final List<dynamic> _selectedItemIds =
      []; // int for local version / String for cloud version

  bool get isSelectionMode => _isSelectionMode;
  List<dynamic> get selectedItemIds => _selectedItemIds;
  int? get targetId => _targetId;

  void enableSelectionMode() {
    _isSelectionMode = true;
    notifyListeners();
  }

  void disableSelectionMode() {
    _isSelectionMode = false;
    _selectedItemIds.clear();
    notifyListeners();
  }

  void toggleItemSelection(dynamic item) {
    if (_selectedItemIds.contains(item)) {
      _selectedItemIds.remove(item);
      if (_selectedItemIds.isEmpty) {
        disableSelectionMode();
      }
    } else {
      _selectedItemIds.add(item);
    }
    notifyListeners();
  }

  void setTarget(int id) {
    _targetId = id;
  }

  bool isItemSelected(dynamic item) {
    return _selectedItemIds.contains(item);
  }

  void clearSelection() {
    _selectedItemIds.clear();
    notifyListeners();
  }
}
