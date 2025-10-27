import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;
  final HiveInterface _hive;

  StorageService(this._prefs, this._secureStorage, this._hive);

  // SharedPreferences methods (for non-sensitive data)
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  Future<bool> clear() async {
    return await _prefs.clear();
  }

  // Secure Storage methods (for sensitive data)
  Future<void> setSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getSecure(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> removeSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> clearSecure() async {
    await _secureStorage.deleteAll();
  }

  Future<Map<String, String>> getAllSecure() async {
    return await _secureStorage.readAll();
  }

  // JSON storage methods
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return await setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getJson(String key) {
    final jsonString = getString(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> setSecureJson(String key, Map<String, dynamic> value) async {
    await setSecure(key, jsonEncode(value));
  }

  Future<Map<String, dynamic>?> getSecureJson(String key) async {
    final jsonString = await getSecure(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Hive box methods (for complex data structures)
  Future<Box<T>> openBox<T>(String boxName) async {
    return await _hive.openBox<T>(boxName);
  }

  Future<LazyBox<T>> openLazyBox<T>(String boxName) async {
    return await _hive.openLazyBox<T>(boxName);
  }

  Future<void> closeBox(String boxName) async {
    final box = _hive.box(boxName);
    await box.close();
  }

  Future<void> deleteBox(String boxName) async {
    await _hive.deleteBoxFromDisk(boxName);
  }

  // User preferences
  Future<void> setUserPreference(String key, dynamic value) async {
    if (value is bool) {
      await setBool('user_pref_$key', value);
    } else if (value is String) {
      await setString('user_pref_$key', value);
    } else if (value is int) {
      await setInt('user_pref_$key', value);
    } else if (value is double) {
      await setDouble('user_pref_$key', value);
    } else if (value is List<String>) {
      await setStringList('user_pref_$key', value);
    } else if (value is Map<String, dynamic>) {
      await setJson('user_pref_$key', value);
    }
  }

  T? getUserPreference<T>(String key) {
    if (T == bool) {
      return getBool('user_pref_$key') as T?;
    } else if (T == String) {
      return getString('user_pref_$key') as T?;
    } else if (T == int) {
      return getInt('user_pref_$key') as T?;
    } else if (T == double) {
      return getDouble('user_pref_$key') as T?;
    } else if (T == List<String>) {
      return getStringList('user_pref_$key') as T?;
    } else if (T == Map<String, dynamic>) {
      return getJson('user_pref_$key') as T?;
    }
    return null;
  }

  // App settings
  Future<void> setThemeMode(String themeMode) async {
    await setString('theme_mode', themeMode);
  }

  String getThemeMode() {
    return getString('theme_mode') ?? 'system';
  }

  Future<void> setLanguage(String languageCode) async {
    await setString('language_code', languageCode);
  }

  String getLanguage() {
    return getString('language_code') ?? 'en';
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await setBool('notifications_enabled', enabled);
  }

  bool getNotificationsEnabled() {
    return getBool('notifications_enabled') ?? true;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await setSecure('biometric_enabled', enabled.toString());
  }

  Future<bool> getBiometricEnabled() async {
    final value = await getSecure('biometric_enabled');
    return value == 'true';
  }

  // Offline data management
  Future<void> setOfflineData(String key, Map<String, dynamic> data) async {
    final box = await openBox<Map>('offline_data');
    await box.put(key, data);
  }

  Future<Map<String, dynamic>?> getOfflineData(String key) async {
    final box = await openBox<Map>('offline_data');
    final data = box.get(key);
    return data?.cast<String, dynamic>();
  }

  Future<void> removeOfflineData(String key) async {
    final box = await openBox<Map>('offline_data');
    await box.delete(key);
  }

  Future<void> clearOfflineData() async {
    final box = await openBox<Map>('offline_data');
    await box.clear();
  }

  Future<List<String>> getOfflineDataKeys() async {
    final box = await openBox<Map>('offline_data');
    return box.keys.cast<String>().toList();
  }

  // Cache management
  Future<void> setCacheData(String key, Map<String, dynamic> data, {Duration? ttl}) async {
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      if (ttl != null) 'ttl': ttl.inMilliseconds,
    };
    
    final box = await openBox<Map>('cache_data');
    await box.put(key, cacheData);
  }

  Future<Map<String, dynamic>?> getCacheData(String key) async {
    final box = await openBox<Map>('cache_data');
    final cacheData = box.get(key)?.cast<String, dynamic>();
    
    if (cacheData == null) return null;
    
    final timestamp = cacheData['timestamp'] as int;
    final ttl = cacheData['ttl'] as int?;
    
    if (ttl != null) {
      final expiryTime = timestamp + ttl;
      if (DateTime.now().millisecondsSinceEpoch > expiryTime) {
        await box.delete(key);
        return null;
      }
    }
    
    return cacheData['data'] as Map<String, dynamic>?;
  }

  Future<void> clearExpiredCache() async {
    final box = await openBox<Map>('cache_data');
    final keysToDelete = <String>[];
    
    for (final key in box.keys) {
      final cacheData = box.get(key)?.cast<String, dynamic>();
      if (cacheData != null) {
        final timestamp = cacheData['timestamp'] as int;
        final ttl = cacheData['ttl'] as int?;
        
        if (ttl != null) {
          final expiryTime = timestamp + ttl;
          if (DateTime.now().millisecondsSinceEpoch > expiryTime) {
            keysToDelete.add(key.toString());
          }
        }
      }
    }
    
    for (final key in keysToDelete) {
      await box.delete(key);
    }
  }
}