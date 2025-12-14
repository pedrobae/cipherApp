import 'package:cipher_app/screens/admin/admin_screen.dart';
import 'package:cipher_app/screens/admin/user_management_screen.dart';
import 'package:cipher_app/screens/signup_screen.dart';
import 'package:cipher_app/screens/main_screen.dart';
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String main = '/main';
  static const String signUp = '/signup';
  static const String admin = '/admin';
  static const String adminUserManagement = '/admin/user-management';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    main: (context) => const MainScreen(),
    signUp: (context) => const SignUpScreen(),
    admin: (context) => const AdminScreen(),
    adminUserManagement: (context) => const UserManagementScreen(),
  };
}
