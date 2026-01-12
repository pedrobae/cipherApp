import 'dart:convert';
import 'package:cordis/models/dtos/version_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CloudVersionsCache {
  static const _cacheKey = 'cloudVersions';
  static const _lastLoadKey = 'lastCloudLoad';

  Future<void> saveCloudVersions(List<VersionDto> versions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = versions.map((v) => v.toCache()).toList();
    await prefs.setString(_cacheKey, json.encode(jsonList));
  }

  Future<List<VersionDto>> loadCloudVersions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);
      if (jsonString == null) return [];
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((j) => VersionDto.fromFirestore(j, j['firebaseId'] as String))
          .toList();
    } catch (e) {
      // If there's an error (e.g., corrupted data), return empty list
      return [];
    }
  }

  Future<void> saveLastCloudLoad(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastLoadKey, time.millisecondsSinceEpoch);
  }

  Future<DateTime?> loadLastCloudLoad() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_lastLoadKey);
    if (millis != null) {
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }
    return null;
  }
}
