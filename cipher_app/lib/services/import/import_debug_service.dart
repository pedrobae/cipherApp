import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Service to save imported text samples for parser development.
/// This helps analyze real-world import patterns before building the parser.
class ImportDebugService {
  static const bool _enableDebugSaving = true; // Set to false to disable

  /// Saves imported text to a debug file for analysis.
  ///
  /// Files are saved in app's support directory: debug_imports/
  /// Format: import_YYYYMMDD_HHMMSS_[type]_[source].txt
  Future<void> saveImportSample({
    required String text,
    required String importType,
    String? sourceFileName,
  }) async {
    if (!_enableDebugSaving) return;
    if (kIsWeb) return; // Skip on web platform

    try {
      // Get timestamp for unique filename
      final now = DateTime.now();
      final timestamp =
          '${now.year}${_pad(now.month)}${_pad(now.day)}_'
          '${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';

      // Build filename
      final filename = 'import_${timestamp}_$importType.txt';

      // Get app support directory (more reliable on Android)
      final appSupportDir = await getApplicationSupportDirectory();
      final debugDir = path.join(appSupportDir.path, 'debug_imports');

      // Ensure directory exists
      final dir = Directory(debugDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Create file with metadata header
      final filePath = path.join(debugDir, filename);
      final file = File(filePath);

      final header =
          '''
================================================================================
IMPORT DEBUG SAMPLE
================================================================================
Timestamp: ${now.toIso8601String()}
Import Type: $importType
Source File: ${sourceFileName ?? 'N/A (direct text input)'}
Text Length: ${text.length} characters
Lines: ${'\n'.allMatches(text).length + 1}
================================================================================

''';

      await file.writeAsString(header + text);

      debugPrint('✅ Import sample saved: $filename');
      debugPrint('📂 Location: $filePath');
    } catch (e) {
      debugPrint('⚠️ Failed to save import sample: $e');
      // Don't throw - this is just debug functionality
    }
  }

  /// Pads single digit numbers with leading zero.
  String _pad(int number) => number.toString().padLeft(2, '0');

  /// Lists all saved import samples (useful for analysis).
  Future<List<FileSystemEntity>> listSavedSamples() async {
    if (kIsWeb) return [];

    try {
      final appSupportDir = await getApplicationSupportDirectory();
      final debugDir = path.join(appSupportDir.path, 'debug_imports');
      final dir = Directory(debugDir);

      if (!await dir.exists()) return [];

      return dir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.txt'))
          .toList();
    } catch (e) {
      debugPrint('Failed to list import samples: $e');
      return [];
    }
  }

  /// Clears all saved import samples.
  Future<void> clearAllSamples() async {
    if (kIsWeb) return;

    try {
      final appSupportDir = await getApplicationSupportDirectory();
      final debugDir = path.join(appSupportDir.path, 'debug_imports');
      final dir = Directory(debugDir);

      if (!await dir.exists()) return;

      await for (var entity in dir.list()) {
        if (entity is File && entity.path.endsWith('.txt')) {
          await entity.delete();
        }
      }

      debugPrint('✅ Cleared all import samples');
    } catch (e) {
      debugPrint('Failed to clear import samples: $e');
    }
  }
}
