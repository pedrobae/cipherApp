import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/domain/info_item.dart';

class InfoService {
  // Initialize database (temp implementation)
  static Future get database async {
    return null; // Placeholder for now
  }

  static Future<List<InfoItem>> getAllInfo() async {
    try {
      // Load mock JSON file
      final String jsonString = await rootBundle.loadString(
        'assets/data/mock_info.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      // Convert to Cipher objects and return
      return jsonList.map((json) => InfoItem.fromJson(json)).toList();
    } catch (e) {
      print(e);
      // Add Log Later
      return [];
    }
    // TODO: Implement when database is ready
  }

  static Future<List<InfoItem>> getInfo({int? limit, int? offset}) async {
    // TODO: Implement when database is ready
    return [];
  }

  static Future<void> closeDatabase() async {
    // TODO: Implement when database is ready
  }
}
