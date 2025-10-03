import 'package:cipher_app/providers/auth_provider.dart';
import 'package:cipher_app/providers/navigation_provider.dart';
import 'package:cipher_app/screens/login_screen.dart';
import 'package:cipher_app/screens/main_screen.dart';
import 'package:cipher_app/screens/admin/admin_bulk_import_screen.dart';
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/cipher_library.dart';
import '../screens/info_screen.dart';
import '../screens/playlist_library.dart';
import '../screens/settings_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String main = '/main';
  static const String login = '/login';
  static const String adminBulkImport = '/admin/bulk-import';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    main: (context) => const MainScreen(),
    login: (context) => const LoginScreen(),
    adminBulkImport: (context) => const AdminBulkImportScreen(),
  };

  static Map<String, Widget> get contentRoutes {
    return {
      NavigationProvider.libraryRoute: const CipherLibraryScreen(),
      NavigationProvider.playlistsRoute: const PlaylistLibraryScreen(),
      NavigationProvider.settingsRoute: const SettingsScreen(),
      NavigationProvider.infoRoute: const InfoScreen(),
      if (AuthProvider().isAdmin)
        NavigationProvider.admin: const AdminBulkImportScreen(),
    };
  }
}
