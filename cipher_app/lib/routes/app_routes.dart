import 'package:flutter/material.dart';
import '../screens/cipher_viewer.dart';
import '../screens/main_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String cipherViewer = '/cipher-viewer';

  static final Map<String, WidgetBuilder> routes = {
    home: (_) => const MainScreen(),
    cipherViewer: (_) => const CipherViewer(),
  };
}