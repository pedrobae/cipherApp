import 'package:cipher_app/utils/design_constants.dart';
import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  static const String libraryRoute = '/library';
  static const String playlistsRoute = '/playlists';
  static const String settingsRoute = '/settings';
  static const String infoRoute = '/info';
  static const String homeRoute = '/home';
  static const String admin = '/admin';
  static const String bulkImportRoute = '/bulk_import';
  static const String userManagementRoute = '/user_management';

  int _selectedIndex = 0;
  String _currentRoute = homeRoute;
  String _previousRoute = '';
  String _routeTitle = appName;
  bool _isLoading = false;
  String? _error;

  // Getters
  String get currentRoute => _currentRoute;
  String get previousRoute => _previousRoute;
  int get selectedIndex => _selectedIndex;
  String get routeTitle => _routeTitle;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Navigation methods following your provider pattern
  void navigateToHome() {
    _navigateToRoute(0, homeRoute);
  }

  void navigateToLibrary() {
    _navigateToRoute(0, libraryRoute);
  }

  void navigateToPlaylists() {
    _navigateToRoute(1, playlistsRoute);
  }

  void navigateToSettings() {
    _navigateToRoute(2, settingsRoute);
  }

  void navigateToInfo() {
    _navigateToRoute(3, infoRoute);
  }

  void navigateToAdmin() {
    _navigateToRoute(4, admin);
  }

  void navigateToBulkImport() {
    _navigateToRoute(5, bulkImportRoute);
  }

  void navigateToUserManagement() {
    _navigateToRoute(6, userManagementRoute);
  }

  void _navigateToRoute(int index, String route) {
    if (_selectedIndex != index || _currentRoute != route) {
      _previousRoute = _currentRoute;
      _selectedIndex = index;
      _currentRoute = route;
      _routeTitle = _getTitleFromRoute(route);
      _error = null; // Clear any previous errors
      notifyListeners();
    }
  }

  // Legacy method for backward compatibility
  void navigateTo(int index, String route) {
    _navigateToRoute(index, route);
  }

  void setCurrentRoute(String route) {
    final index = _getIndexFromRoute(route);
    _navigateToRoute(index, route);
  }

  // Error handling following your provider pattern
  void setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Loading state management
  void setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _error = null; // Clear errors when starting to load
    }
    notifyListeners();
  }

  int _getIndexFromRoute(String route) {
    switch (route) {
      case homeRoute:
      case libraryRoute:
        return 0;
      case playlistsRoute:
        return 1;
      case settingsRoute:
        return 2;
      case infoRoute:
        return 3;
      case admin:
        return 4;
      case bulkImportRoute:
        return 5;
      case userManagementRoute:
        return 6;
      default:
        return -1;
    }
  }

  String _getTitleFromRoute(String route) {
    switch (route) {
      case libraryRoute:
        return 'Biblioteca';
      case playlistsRoute:
        return 'Playlists';
      case settingsRoute:
        return 'Configurações';
      case infoRoute:
        return 'Informações';
      case homeRoute:
        return appName;
      case admin:
        return 'Administração';
      case bulkImportRoute:
        return 'Importação em Massa';
      case userManagementRoute:
        return 'Gerenciamento de Usuários';
      default:
        return 'App de Cifras';
    }
  }

  // Get available navigation items for bottom navigation
  NavigationItem getLibraryItem({Color? iconColor, double iconSize = 64}) {
    return NavigationItem(
      route: libraryRoute,
      title: 'Biblioteca',
      icon: Icon(Icons.library_music, color: iconColor, size: iconSize),
      index: 0,
    );
  }

  NavigationItem getPlaylistItem({Color? iconColor, double iconSize = 64}) {
    return NavigationItem(
      route: playlistsRoute,
      title: 'Playlists',
      icon: Icon(Icons.playlist_play, color: iconColor, size: iconSize),
      index: 1,
    );
  }

  NavigationItem getSettingsItem({Color? iconColor, double iconSize = 64}) {
    return NavigationItem(
      route: settingsRoute,
      title: 'Configurações',
      icon: Icon(Icons.settings, color: iconColor, size: iconSize),
      index: 2,
    );
  }

  NavigationItem getInfoItem({Color? iconColor, double iconSize = 64}) {
    return NavigationItem(
      route: infoRoute,
      title: 'Informações',
      icon: Icon(Icons.info, color: iconColor, size: iconSize),
      index: 3,
    );
  }

  NavigationItem getAdminItem({Color? iconColor, double iconSize = 64}) {
    return NavigationItem(
      route: admin,
      title: 'Administração',
      icon: Icon(Icons.admin_panel_settings, color: iconColor, size: iconSize),
      index: 4,
    );
  }

  AdminItem getBulkImportItem({Color? iconColor, double iconSize = 64}) {
    return AdminItem(
      route: bulkImportRoute,
      title: 'Importação em Massa',
      icon: Icon(Icons.upload_file, color: iconColor, size: iconSize),
      index: 5,
    );
  }

  AdminItem getUserManagementItem({Color? iconColor, double iconSize = 64}) {
    return AdminItem(
      route: '/user_management',
      title: 'Gerenciamento de Usuários',
      icon: Icon(
        Icons.supervised_user_circle,
        color: iconColor,
        size: iconSize,
      ),
      index: 6,
    );
  }

  // Compose navigation lists as needed
  List<NavigationItem> getNavigationItems({
    Color? iconColor,
    double iconSize = 64,
  }) {
    return [
      getLibraryItem(iconColor: iconColor, iconSize: iconSize),
      getPlaylistItem(iconColor: iconColor, iconSize: iconSize),
      getSettingsItem(iconColor: iconColor, iconSize: iconSize),
      getInfoItem(iconColor: iconColor, iconSize: iconSize),
    ];
  }

  List<AdminItem> getAdminItems({Color? iconColor, double iconSize = 64}) {
    return [
      getBulkImportItem(iconColor: iconColor, iconSize: iconSize),
      getUserManagementItem(iconColor: iconColor, iconSize: iconSize),
    ];
  }
}

// Helper class for navigation items
class NavigationItem {
  final String route;
  final String title;
  final Icon icon;
  final int index;

  NavigationItem({
    required this.route,
    required this.title,
    required this.icon,
    required this.index,
  });
}

// Helper class for admin items
class AdminItem {
  final String route;
  final String title;
  final Icon icon;
  final int index;

  AdminItem({
    required this.route,
    required this.title,
    required this.icon,
    required this.index,
  });
}
