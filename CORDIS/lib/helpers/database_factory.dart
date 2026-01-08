import 'package:flutter/foundation.dart';

class DatabaseFactoryHelper {
  /// Initializes the appropriate database factory based on the current platform.
  ///
  /// - **Mobile (iOS/Android)**: Uses native sqflite
  /// - **Desktop (Windows/Linux/macOS)**: Uses sqflite_common_ffi
  /// - **Web**: Throws UnsupportedError (sqflite doesn't work on web)
  static Future<void> initialize() async {
    if (kIsWeb) {
      // Web platform - sqflite doesn't work on web
      throw UnsupportedError(
        'Database operations are not supported on web platform. '
        'Consider using shared_preferences, IndexedDB wrapper, or Firebase Firestore.',
      );
    } else {
      // Mobile platforms (iOS, Android) - sqflite works natively
      // No additional setup needed
      if (kDebugMode) {
        print(
          'Using native sqflite for mobile platform (${defaultTargetPlatform.name})',
        );
      }
    }
  }
}
