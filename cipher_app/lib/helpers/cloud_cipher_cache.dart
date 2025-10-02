import 'dart:convert';
import 'package:cipher_app/models/dtos/cipher_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CloudCipherCache {
  static const _cacheKey = 'cloudCiphers';
  static const _lastLoadKey = 'lastCloudLoad';

  Future<void> saveCloudCiphers(List<CipherDto> ciphers) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = ciphers.map((c) => c.toMap()).toList();
    await prefs.setString(_cacheKey, json.encode(jsonList));
  }

  Future<List<CipherDto>> loadCloudCiphers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((j) => CipherDto.fromMap(j)).toList();
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
