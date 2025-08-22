import 'package:flutter/foundation.dart';
import '../models/domain/info_item.dart';
import '../services/info_service.dart';

class InfoProvider extends ChangeNotifier {
  List<InfoItem> _infoItems = [];
  bool _isLoading = false;
  String? _error;
  InfoType? _selectedType;

  List<InfoItem> get infoItems => _selectedType == null
      ? _infoItems
      : _infoItems.where((item) => item.type == _selectedType).toList();

  bool get isLoading => _isLoading;
  String? get error => _error;
  InfoType? get selectedType => _selectedType;

  Future<void> loadInfo() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));
      _infoItems = await InfoService.getAllInfo();
    } catch (e) {
      _error = 'Failed to load info items: \n $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void filterByType(InfoType? type) {
    _selectedType = type;
    notifyListeners();
  }

  Future<void> refresh() async {
    loadInfo();
  }

  List<InfoItem> getRecentItems({int limit = 5}) {
    final sorted = List<InfoItem>.from(_infoItems);
    sorted.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return sorted.take(limit).toList();
  }
}
