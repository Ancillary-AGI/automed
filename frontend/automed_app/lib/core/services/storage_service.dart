import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  StorageService({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  // Secure storage methods (for sensitive data)
  Future<void> saveSecureData(String key, String value) async {
    await secureStorage.write(key: key, value: value);
  }

  Future<String?> getSecureData(String key) async {
    return await secureStorage.read(key: key);
  }

  Future<void> deleteSecureData(String key) async {
    await secureStorage.delete(key: key);
  }

  Future<void> clearAllSecureData() async {
    await secureStorage.deleteAll();
  }

  // Shared preferences methods (for non-sensitive data)
  Future<void> saveString(String key, String value) async {
    await sharedPreferences.setString(key, value);
  }

  Future<void> saveInt(String key, int value) async {
    await sharedPreferences.setInt(key, value);
  }

  Future<void> saveBool(String key, bool value) async {
    await sharedPreferences.setBool(key, value);
  }

  Future<void> saveDouble(String key, double value) async {
    await sharedPreferences.setDouble(key, value);
  }

  Future<void> saveStringList(String key, List<String> value) async {
    await sharedPreferences.setStringList(key, value);
  }

  String? getString(String key) {
    return sharedPreferences.getString(key);
  }

  int? getInt(String key) {
    return sharedPreferences.getInt(key);
  }

  bool? getBool(String key) {
    return sharedPreferences.getBool(key);
  }

  double? getDouble(String key) {
    return sharedPreferences.getDouble(key);
  }

  List<String>? getStringList(String key) {
    return sharedPreferences.getStringList(key);
  }

  Future<void> remove(String key) async {
    await sharedPreferences.remove(key);
  }

  Future<void> clearAll() async {
    await sharedPreferences.clear();
  }

  bool containsKey(String key) {
    return sharedPreferences.containsKey(key);
  }

  Set<String> getKeys() {
    return sharedPreferences.getKeys();
  }

  // User preferences
  Future<void> saveUserPreference(String key, dynamic value) async {
    final prefKey = 'user_pref_$key';
    if (value is String) {
      await saveString(prefKey, value);
    } else if (value is int) {
      await saveInt(prefKey, value);
    } else if (value is bool) {
      await saveBool(prefKey, value);
    } else if (value is double) {
      await saveDouble(prefKey, value);
    } else if (value is List<String>) {
      await saveStringList(prefKey, value);
    }
  }

  dynamic getUserPreference(String key) {
    final prefKey = 'user_pref_$key';
    // Try different types
    return getString(prefKey) ??
           getInt(prefKey) ??
           getBool(prefKey) ??
           getDouble(prefKey) ??
           getStringList(prefKey);
  }

  // App settings
  Future<void> saveAppSetting(String key, dynamic value) async {
    final settingKey = 'app_setting_$key';
    if (value is String) {
      await saveString(settingKey, value);
    } else if (value is int) {
      await saveInt(settingKey, value);
    } else if (value is bool) {
      await saveBool(settingKey, value);
    } else if (value is double) {
      await saveDouble(settingKey, value);
    }
  }

  dynamic getAppSetting(String key) {
    final settingKey = 'app_setting_$key';
    return getString(settingKey) ??
           getInt(settingKey) ??
           getBool(settingKey) ??
           getDouble(settingKey);
  }

  // Cache management
  Future<void> saveCacheData(String key, String data, {Duration? expiry}) async {
    final cacheKey = 'cache_$key';
    final timestampKey = 'cache_timestamp_$key';

    await saveString(cacheKey, data);
    await saveInt(timestampKey, DateTime.now().millisecondsSinceEpoch);

    if (expiry != null) {
      final expiryKey = 'cache_expiry_$key';
      final expiryTime = DateTime.now().add(expiry).millisecondsSinceEpoch;
      await saveInt(expiryKey, expiryTime);
    }
  }

  String? getCacheData(String key) {
    final cacheKey = 'cache_$key';
    final timestampKey = 'cache_timestamp_$key';
    final expiryKey = 'cache_expiry_$key';

    final data = getString(cacheKey);
    final timestamp = getInt(timestampKey);
    final expiry = getInt(expiryKey);

    if (data == null || timestamp == null) {
      return null;
    }

    // Check if cache has expired
    if (expiry != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now > expiry) {
        // Cache expired, remove it
        remove(cacheKey);
        remove(timestampKey);
        remove(expiryKey);
        return null;
      }
    }

    return data;
  }

  Future<void> clearExpiredCache() async {
    final keys = getKeys();
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final key in keys) {
      if (key.startsWith('cache_expiry_')) {
        final expiryTime = getInt(key);
        if (expiryTime != null && now > expiryTime) {
          // Remove expired cache
          final cacheKey = key.replaceFirst('cache_expiry_', 'cache_');
          final timestampKey = key.replaceFirst('cache_expiry_', 'cache_timestamp_');

          remove(cacheKey);
          remove(timestampKey);
          remove(key);
        }
      }
    }
  }

  // Session management
  Future<void> saveSessionData(Map<String, dynamic> sessionData) async {
    final jsonString = sessionData.toString(); // Simplified - should use json.encode
    await saveSecureData('session_data', jsonString);
  }

  Future<Map<String, dynamic>?> getSessionData() async {
    final jsonString = await getSecureData('session_data');
    if (jsonString != null) {
      // Simplified - should use json.decode
      return {'session': jsonString};
    }
    return null;
  }

  Future<void> clearSessionData() async {
    await deleteSecureData('session_data');
  }

  // Device-specific data
  Future<void> saveDeviceId(String deviceId) async {
    await saveSecureData('device_id', deviceId);
  }

  Future<String?> getDeviceId() async {
    return await getSecureData('device_id');
  }

  // Analytics and tracking
  Future<void> saveAnalyticsData(String event, Map<String, dynamic> data) async {
    final analyticsKey = 'analytics_${DateTime.now().millisecondsSinceEpoch}';
    final jsonString = data.toString(); // Simplified
    await saveString(analyticsKey, jsonString);
  }

  // Storage statistics
  Map<String, dynamic> getStorageStats() {
    final keys = getKeys();
    final secureKeys = <String>[]; // We can't enumerate secure storage keys

    return {
      'shared_preferences_keys': keys.length,
      'secure_storage_keys': secureKeys.length,
      'total_keys': keys.length + secureKeys.length,
      'user_preferences': keys.where((key) => key.startsWith('user_pref_')).length,
      'app_settings': keys.where((key) => key.startsWith('app_setting_')).length,
      'cache_entries': keys.where((key) => key.startsWith('cache_')).length,
    };
  }
}