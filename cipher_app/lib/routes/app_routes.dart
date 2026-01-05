import 'package:cipher_app/screens/admin/admin_screen.dart';
import 'package:cipher_app/screens/admin/user_management_screen.dart';
import 'package:cipher_app/screens/login_screen.dart';
import 'package:cipher_app/screens/signup_screen.dart';
import 'package:cipher_app/screens/main_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String main = '/';
  static const String signUp = '/signup';
  static const String login = '/login';
  static const String admin = '/admin';
  static const String adminUserManagement = '/admin/user-management';

  static Map<String, WidgetBuilder> routes = {
    main: (context) => const MainScreen(),
    signUp: (context) => const SignUpScreen(),
    login: (context) => const LoginScreen(),
    admin: (context) => const AdminScreen(),
    adminUserManagement: (context) => const UserManagementScreen(),
  };
}
