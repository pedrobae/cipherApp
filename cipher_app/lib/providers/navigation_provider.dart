import 'package:cipher_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

enum NavigationRoute { home, library, playlists }

class NavigationProvider extends ChangeNotifier {
  NavigationRoute _currentRoute = NavigationRoute.home;
  bool _isLoading = false;
  String? _error;

  // Getters
  NavigationRoute get currentRoute => _currentRoute;
  int get currentIndex => _currentRoute.index;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// USED BY THE MAIN SCREEN TO NAVIGATE BETWEEN CONTENT TABS

  // Navigation methods following your provider pattern
  void navigateToRoute(NavigationRoute route) {
    if (_currentRoute != route) {
      _currentRoute = route;
      _error = null; // Clear any previous errors
      notifyListeners();
    }
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

  NavigationItem getNavigationItem(
    BuildContext context,
    NavigationRoute route, {
    Color? iconColor,
    double iconSize = 64,
  }) {
    return NavigationItem(
      route: route,
      title: _getTitleForRoute(context, route),
      icon: _getIconForRoute(route, iconColor: iconColor, iconSize: iconSize),
      index: route.index,
    );
  }

  String _getTitleForRoute(BuildContext context, NavigationRoute route) {
    switch (route) {
      case NavigationRoute.home:
        return AppLocalizations.of(context)!.home;
      case NavigationRoute.library:
        return AppLocalizations.of(context)!.library;
      case NavigationRoute.playlists:
        return AppLocalizations.of(context)!.playlists;
    }
  }

  Icon _getIconForRoute(
    NavigationRoute route, {
    Color? iconColor,
    double iconSize = 64,
  }) {
    switch (route) {
      case NavigationRoute.home:
        return Icon(Icons.home, color: iconColor, size: iconSize);
      case NavigationRoute.library:
        return Icon(Icons.library_music, color: iconColor, size: iconSize);
      case NavigationRoute.playlists:
        return Icon(Icons.playlist_play, color: iconColor, size: iconSize);
    }
  }

  // Compose navigation lists as needed
  List<NavigationItem> getNavigationItems(
    BuildContext context, {
    Color? iconColor,
    double iconSize = 64,
  }) {
    return [
      for (var route in NavigationRoute.values)
        getNavigationItem(
          context,
          route,
          iconColor: iconColor,
          iconSize: iconSize,
        ),
    ];
  }
}

// Helper class for navigation items
class NavigationItem {
  final NavigationRoute route;
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

class AdminNavigationItem {
  final String title;
  final Icon icon;

  AdminNavigationItem({required this.title, required this.icon});
}

extension NavigationProviderAdmin on NavigationProvider {
  List<AdminNavigationItem> getAdminItems({
    Color? iconColor,
    double iconSize = 64,
  }) {
    return [
      AdminNavigationItem(
        title: 'Gerenciamento de Usuários',
        icon: Icon(Icons.manage_accounts, color: iconColor, size: iconSize),
      ),
      // Add more admin items here as needed
    ];
  }
}
