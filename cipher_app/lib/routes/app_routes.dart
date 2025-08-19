import 'package:flutter/material.dart';
import '../screens/library_screen.dart';
import '../screens/playlist_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/info_screen.dart';
import '../screens/cipher_viewer.dart';

class AppRoutes {
  static const String library = '/library';
  static const String playlists = '/playlists';
  static const String settings = '/settings';
  static const String info = '/info';
  static const String cipherViewer = '/cipher-viewer';

  static final Map<String, WidgetBuilder> routes = {
    library: (_) => const LibraryScreen(),
    playlists: (_) => const PlaylistScreen(),
    settings: (_) => const SettingsScreen(),
    info: (_) => const InfoScreen(),
    cipherViewer: (_) => const CipherViewer(),
  };
}