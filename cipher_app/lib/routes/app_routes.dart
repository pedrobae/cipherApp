import 'package:flutter/material.dart';
import '../screens/main_screen.dart';
import '../screens/library_screen.dart';
import '../screens/edit_cipher.dart';
import '../screens/info_screen.dart';
import '../screens/playlist_screen.dart';
import '../screens/settings_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String library = '/library';
  static const String editCipher = '/edit-cipher';
  static const String cipherViewer = '/cipher-viewer';
  static const String info = '/info';
  static const String playlists = '/playlists';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const MainScreen(),
    library: (context) => const LibraryScreen(),
    editCipher: (context) => const EditCipher(),
    // Note: CipherViewer now requires a cipher parameter, so direct route navigation 
    // should use Navigator.push with MaterialPageRoute instead of named routes
    info: (context) => const InfoScreen(),
    playlists: (context) => const PlaylistScreen(),
    settings: (context) => const SettingsScreen(),
  };
}
