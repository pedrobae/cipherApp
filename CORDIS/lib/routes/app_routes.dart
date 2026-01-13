import 'package:cordis/screens/admin/admin_screen.dart';
import 'package:cordis/screens/admin/user_management_screen.dart';
import 'package:cordis/screens/login_screen.dart';
import 'package:cordis/screens/settings_screen.dart';
import 'package:cordis/screens/signup_screen.dart';
import 'package:cordis/screens/main_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String main = '/';
  static const String signUp = '/signup';
  static const String login = '/login';
  static const String admin = '/admin';
  static const String adminUserManagement = '/admin/user-management';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> routes = {
    main: (context) => const MainScreen(),
    signUp: (context) => const SignUpScreen(),
    login: (context) => const LoginScreen(),
    admin: (context) => const AdminScreen(),
    adminUserManagement: (context) => const UserManagementScreen(),
    settings: (context) => const SettingsScreen(),
  };
}
