import 'package:flutter/material.dart';
import '../screens/main_screen.dart';
import '../screens/cipher_library.dart';
import '../screens/cipher_editor.dart';
import '../screens/info_screen.dart';
import '../screens/playlist_library.dart';
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
    library: (context) => const CipherLibraryScreen(),
    editCipher: (context) => const EditCipher(),
    // Note: CipherViewer now requires a cipher parameter, so direct route navigation
    // should use Navigator.push with MaterialPageRoute instead of named routes
    info: (context) => const InfoScreen(),
    playlists: (context) => const PlaylistLibraryScreen(),
    settings: (context) => const SettingsScreen(),
  };

  static Map<String, Widget?> contentRoutes = {
    library: const CipherLibraryScreen(),
    playlists: const PlaylistLibraryScreen(),
    settings: const SettingsScreen(),
    info: const InfoScreen(),
  };
}
