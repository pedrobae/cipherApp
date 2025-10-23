import 'package:cipher_app/providers/navigation_provider.dart';
import 'package:cipher_app/screens/admin/admin_screen.dart';
import 'package:cipher_app/screens/admin/user_management_screen.dart';
import 'package:cipher_app/screens/login_screen.dart';
import 'package:cipher_app/screens/signup_screen.dart';
import 'package:cipher_app/screens/main_screen.dart';
import 'package:cipher_app/screens/admin/bulk_import_screen.dart';
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/cipher/cipher_library.dart';
import '../screens/info_screen.dart';
import '../screens/playlist/playlist_library.dart';
import '../screens/settings_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String main = '/main';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String admin = '/admin';
  static const String adminBulkImport = '/admin/bulk-import';
  static const String adminUserManagement = '/admin/user-management';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    main: (context) => const MainScreen(),
    login: (context) => const LoginScreen(),
    signUp: (context) => const SignUpScreen(),
    admin: (context) => const AdminScreen(),
    adminBulkImport: (context) => const BulkImportScreen(),
    adminUserManagement: (context) => const UserManagementScreen(),
  };

  static Map<String, Widget> contentRoutes(bool isAdmin) {
    return {
      NavigationProvider.libraryRoute: const CipherLibraryScreen(),
      NavigationProvider.playlistsRoute: const PlaylistLibraryScreen(),
      NavigationProvider.settingsRoute: const SettingsScreen(),
      NavigationProvider.infoRoute: const InfoScreen(),
      if (isAdmin) NavigationProvider.admin: const BulkImportScreen(),
    };
  }
}
