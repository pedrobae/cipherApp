import 'package:flutter/foundation.dart';

class NavigationProvider extends ChangeNotifier {
  static const String libraryRoute = '/library';
  static const String playlistsRoute = '/playlists';
  static const String settingsRoute = '/settings';
  static const String infoRoute = '/info';
  static const String cipherViewerRoute = '/cipher-viewer';

  int _selectedIndex = 0;
  String _currentRoute = libraryRoute;
  String _routeTitle = 'Library';

  String get currentRoute => _currentRoute;
  int get selectedIndex => _selectedIndex;
  String get routeTitle => _routeTitle;

  void navigateTo(int index, String route) {
    if (_selectedIndex != index || _currentRoute != route) {
      _selectedIndex = index;
      _currentRoute = route;
      _routeTitle = _getTitleFromRoute(route);
      notifyListeners();
    }
  }

  void setCurrentRoute(String route) {
    final index = _getIndexFromRoute(route);
    if (index != -1) {
      navigateTo(index, route);
    }
  }

  int _getIndexFromRoute(String route) {
    switch (route) {
      case libraryRoute:
        return 0;
      case playlistsRoute:
        return 1;
      case settingsRoute:
        return 2;
      case infoRoute:
        return 3;
      default:
        return -1;
    }
  }

  String _getTitleFromRoute(String route) {
    switch (route) {
      case libraryRoute:
        return 'Library';
      case playlistsRoute:
        return 'Playlists';
      case settingsRoute:
        return 'Settings';
      case infoRoute:
        return 'Info';
      case cipherViewerRoute:
        return 'Cipher Viewer';
      default:
        return 'Cipher App';
    }
  }
}