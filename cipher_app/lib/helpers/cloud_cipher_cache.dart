import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cipher_app/models/domain/cipher/cipher.dart';

class CloudCipherCache {
  static const _cacheKey = 'cloudCiphers';
  static const _lastLoadKey = 'lastCloudLoad';

  Future<void> saveCloudCiphers(List<Cipher> ciphers) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = ciphers.map((c) => c.toCache()).toList();
    await prefs.setString(_cacheKey, json.encode(jsonList));
  }

  Future<List<Cipher>> loadCloudCiphers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((j) => Cipher.fromJson(j)).toList();
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
