import 'package:cordis/providers/navigation_provider.dart';
import 'package:cordis/screens/admin/admin_screen.dart';
import 'package:cordis/screens/admin/user_management_screen.dart';
import 'package:cordis/screens/login_screen.dart';
import 'package:cordis/screens/signup_screen.dart';
import 'package:cordis/screens/main_screen.dart';
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
  static const String adminUserManagement = '/admin/user-management';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    main: (context) => const MainScreen(),
    login: (context) => const LoginScreen(),
    signUp: (context) => const SignUpScreen(),
    admin: (context) => const AdminScreen(),
    adminUserManagement: (context) => const UserManagementScreen(),
  };

  static Map<String, Widget> contentRoutes(bool isAdmin) {
    return {
      NavigationProvider.libraryRoute: const CipherLibraryScreen(),
      NavigationProvider.playlistsRoute: const PlaylistLibraryScreen(),
      NavigationProvider.settingsRoute: const SettingsScreen(),
      NavigationProvider.infoRoute: const InfoScreen(),
      if (isAdmin) NavigationProvider.admin: const AdminScreen(),
    };
  }

  static Map<String, Widget> adminRoutes() {
    return {
      NavigationProvider.userManagementRoute: const UserManagementScreen(),
    };
  }
}
