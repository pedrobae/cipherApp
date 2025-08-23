import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/services.dart';
import '../models/domain/cipher.dart';

class CipherService {
  // Initialize database (temp implementation)
  static Future get database async {
    return null; // Placeholder for now
  }

  // Future database methods (placeholders)
  static Future<int> getCipherCount() async {
    // TODO: Implement when database is ready
    return 4;
  }

  static Future<List<Cipher>> getAllCiphers() async {
    try {
      // Load mock JSON file
      final String jsonString = await rootBundle.loadString('assets/data/mock_cipher.json');
      
      // Parse JSON in background isolate
      final List<Cipher> ciphers = await _parseJsonInIsolate(jsonString);
      return List.from(ciphers);
    } catch (e) {
        // Add Log Later
        return [];
    }
    // TODO: Implement when database is ready
  }

  static Future<List<Cipher>> getCiphers({int? limit, int? offset}) async {
    // TODO: Implement when database is ready
    return [];
  }

  static Future<List<Cipher>> searchCiphers(String term) async {
    // TODO: Implement when database is ready
    return [];
  }

  static Future<void> addToPlaylist(int cipherId, String playlistId) async {
    // TODO: Implement playlist functionality
  }

  static Future<void> closeDatabase() async {
    // TODO: Implement when database is ready
  }

    // Heavy JSON parsing in background thread
  static Future<List<Cipher>> _parseJsonInIsolate(String jsonString) async {
    return await Isolate.run(() {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Cipher.fromJson(json)).toList();
    });
  }
}