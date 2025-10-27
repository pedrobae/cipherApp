import 'package:flutter/foundation.dart';
import '../models/domain/info_item.dart';
import '../repositories/info_repository.dart';

class InfoProvider extends ChangeNotifier {
  final InfoRepository _infoRepository = InfoRepository();

  List<InfoItem> _infoItems = [];
  bool _isLoading = false;
  String? _error;
  InfoType? _selectedType;

  List<InfoItem> get infoItems {
    List<InfoItem> items = _selectedType == null
        ? _infoItems
        : _infoItems.where((item) => item.type == _selectedType).toList();

    return items;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  InfoType? get selectedType => _selectedType;

  Future<void> loadInfo() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _infoItems = await _infoRepository.getAllInfo();

      // Clear expired info items in background
      _infoRepository.clearExpiredInfo();
    } catch (e) {
      _error = 'Erro ao carregar informações: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterByType(InfoType? type) {
    if (_selectedType != type) {
      _selectedType = type;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _selectedType = null;
    await loadInfo();
  }

  List<InfoItem> getRecentItems({int limit = 5}) {
    final sorted = List<InfoItem>.from(_infoItems);
    sorted.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return sorted.take(limit).toList();
  }

  List<InfoItem> getItemsByType(InfoType type) {
    return _infoItems.where((item) => item.type == type).toList();
  }

  Future<InfoItem?> getInfoById(String id) async {
    try {
      return await _infoRepository.getInfoById(id);
    } catch (e) {
      _error = 'Erro ao buscar informação: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> createInfo(InfoItem infoItem) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _infoRepository.createInfo(infoItem);
      if (result > 0) {
        await loadInfo(); // Reload to get fresh data
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Erro ao criar informação: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateInfo(InfoItem infoItem) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _infoRepository.updateInfo(infoItem);
      await loadInfo(); // Reload to get fresh data
      return true;
    } catch (e) {
      _error = 'Erro ao atualizar informação: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteInfo(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _infoRepository.deleteInfo(id);
      await loadInfo(); // Reload to get fresh data
      return true;
    } catch (e) {
      _error = 'Erro ao excluir informação: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get statistics about info items
  Map<InfoType, int> getInfoStatistics() {
    final stats = <InfoType, int>{};
    for (final type in InfoType.values) {
      stats[type] = _infoItems.where((item) => item.type == type).length;
    }
    return stats;
  }

  // Clear all filters and search
  void clearFilters() {
    _selectedType = null;
    notifyListeners();
  }

  /// Clear cached data and reset state for debugging
  void clearCache() {
    _infoItems.clear();
    _isLoading = false;
    _error = null;
    _selectedType = null;
    notifyListeners();
  }
}
