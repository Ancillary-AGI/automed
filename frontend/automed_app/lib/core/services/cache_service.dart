import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  final HiveInterface _hive;
  static const String _cacheBoxName = 'app_cache';
  static const String _imagesCacheBoxName = 'images_cache';
  static const String _apiCacheBoxName = 'api_cache';

  CacheService(this._hive);

  // Generic cache methods
  Future<void> put(String key, dynamic value, {Duration? ttl}) async {
    final box = await _getCacheBox();
    final cacheItem = CacheItem(
      data: value,
      timestamp: DateTime.now(),
      ttl: ttl,
    );
    await box.put(key, cacheItem.toJson());
  }

  Future<T?> get<T>(String key) async {
    final box = await _getCacheBox();
    final cacheData = box.get(key);
    
    if (cacheData == null) return null;
    
    final cacheItem = CacheItem.fromJson(cacheData);
    
    // Check if cache item has expired
    if (cacheItem.isExpired) {
      await box.delete(key);
      return null;
    }
    
    return cacheItem.data as T?;
  }

  Future<void> remove(String key) async {
    final box = await _getCacheBox();
    await box.delete(key);
  }

  Future<void> clear() async {
    final box = await _getCacheBox();
    await box.clear();
  }

  Future<bool> contains(String key) async {
    final box = await _getCacheBox();
    return box.containsKey(key);
  }

  Future<List<String>> getKeys() async {
    final box = await _getCacheBox();
    return box.keys.cast<String>().toList();
  }

  // API response cache
  Future<void> cacheApiResponse(String endpoint, Map<String, dynamic> response, {Duration? ttl}) async {
    final box = await _getApiCacheBox();
    final cacheItem = CacheItem(
      data: response,
      timestamp: DateTime.now(),
      ttl: ttl ?? const Duration(minutes: 15), // Default 15 minutes for API cache
    );
    await box.put(endpoint, cacheItem.toJson());
  }

  Future<Map<String, dynamic>?> getCachedApiResponse(String endpoint) async {
    final box = await _getApiCacheBox();
    final cacheData = box.get(endpoint);
    
    if (cacheData == null) return null;
    
    final cacheItem = CacheItem.fromJson(cacheData);
    
    if (cacheItem.isExpired) {
      await box.delete(endpoint);
      return null;
    }
    
    return cacheItem.data as Map<String, dynamic>?;
  }

  Future<void> clearApiCache() async {
    final box = await _getApiCacheBox();
    await box.clear();
  }

  // Image cache
  Future<void> cacheImage(String url, List<int> imageData, {Duration? ttl}) async {
    final box = await _getImagesCacheBox();
    final cacheItem = CacheItem(
      data: imageData,
      timestamp: DateTime.now(),
      ttl: ttl ?? const Duration(days: 7), // Default 7 days for images
    );
    await box.put(url, cacheItem.toJson());
  }

  Future<List<int>?> getCachedImage(String url) async {
    final box = await _getImagesCacheBox();
    final cacheData = box.get(url);
    
    if (cacheData == null) return null;
    
    final cacheItem = CacheItem.fromJson(cacheData);
    
    if (cacheItem.isExpired) {
      await box.delete(url);
      return null;
    }
    
    return (cacheItem.data as List).cast<int>();
  }

  Future<void> clearImageCache() async {
    final box = await _getImagesCacheBox();
    await box.clear();
  }

  // User data cache
  Future<void> cacheUserData(String userId, Map<String, dynamic> userData) async {
    await put('user_$userId', userData, ttl: const Duration(hours: 1));
  }

  Future<Map<String, dynamic>?> getCachedUserData(String userId) async {
    return await get<Map<String, dynamic>>('user_$userId');
  }

  // Patient data cache
  Future<void> cachePatientData(String patientId, Map<String, dynamic> patientData) async {
    await put('patient_$patientId', patientData, ttl: const Duration(minutes: 30));
  }

  Future<Map<String, dynamic>?> getCachedPatientData(String patientId) async {
    return await get<Map<String, dynamic>>('patient_$patientId');
  }

  // Consultation data cache
  Future<void> cacheConsultationData(String consultationId, Map<String, dynamic> consultationData) async {
    await put('consultation_$consultationId', consultationData, ttl: const Duration(minutes: 15));
  }

  Future<Map<String, dynamic>?> getCachedConsultationData(String consultationId) async {
    return await get<Map<String, dynamic>>('consultation_$consultationId');
  }

  // Medical records cache
  Future<void> cacheMedicalRecords(String patientId, List<Map<String, dynamic>> records) async {
    await put('medical_records_$patientId', records, ttl: const Duration(hours: 2));
  }

  Future<List<Map<String, dynamic>>?> getCachedMedicalRecords(String patientId) async {
    final cached = await get<List>('medical_records_$patientId');
    return cached?.cast<Map<String, dynamic>>();
  }

  // Medication cache
  Future<void> cacheMedications(String patientId, List<Map<String, dynamic>> medications) async {
    await put('medications_$patientId', medications, ttl: const Duration(hours: 1));
  }

  Future<List<Map<String, dynamic>>?> getCachedMedications(String patientId) async {
    final cached = await get<List>('medications_$patientId');
    return cached?.cast<Map<String, dynamic>>();
  }

  // AI analysis cache
  Future<void> cacheAIAnalysis(String analysisKey, Map<String, dynamic> analysis) async {
    await put('ai_analysis_$analysisKey', analysis, ttl: const Duration(hours: 24));
  }

  Future<Map<String, dynamic>?> getCachedAIAnalysis(String analysisKey) async {
    return await get<Map<String, dynamic>>('ai_analysis_$analysisKey');
  }

  // Cache maintenance
  Future<void> clearExpiredItems() async {
    final boxes = [
      await _getCacheBox(),
      await _getApiCacheBox(),
      await _getImagesCacheBox(),
    ];

    for (final box in boxes) {
      final keysToDelete = <String>[];
      
      for (final key in box.keys) {
        final cacheData = box.get(key);
        if (cacheData != null) {
          final cacheItem = CacheItem.fromJson(cacheData);
          if (cacheItem.isExpired) {
            keysToDelete.add(key.toString());
          }
        }
      }
      
      for (final key in keysToDelete) {
        await box.delete(key);
      }
    }
  }

  Future<int> getCacheSize() async {
    final boxes = [
      await _getCacheBox(),
      await _getApiCacheBox(),
      await _getImagesCacheBox(),
    ];

    int totalSize = 0;
    for (final box in boxes) {
      totalSize += box.length;
    }
    
    return totalSize;
  }

  Future<void> clearAllCache() async {
    await clear();
    await clearApiCache();
    await clearImageCache();
  }

  // Private methods
  Future<Box> _getCacheBox() async {
    if (!_hive.isBoxOpen(_cacheBoxName)) {
      return await _hive.openBox(_cacheBoxName);
    }
    return _hive.box(_cacheBoxName);
  }

  Future<Box> _getApiCacheBox() async {
    if (!_hive.isBoxOpen(_apiCacheBoxName)) {
      return await _hive.openBox(_apiCacheBoxName);
    }
    return _hive.box(_apiCacheBoxName);
  }

  Future<Box> _getImagesCacheBox() async {
    if (!_hive.isBoxOpen(_imagesCacheBoxName)) {
      return await _hive.openBox(_imagesCacheBoxName);
    }
    return _hive.box(_imagesCacheBoxName);
  }
}

class CacheItem {
  final dynamic data;
  final DateTime timestamp;
  final Duration? ttl;

  CacheItem({
    required this.data,
    required this.timestamp,
    this.ttl,
  });

  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().isAfter(timestamp.add(ttl!));
  }

  Map<String, dynamic> toJson() => {
    'data': data,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'ttl': ttl?.inMilliseconds,
  };

  factory CacheItem.fromJson(Map<String, dynamic> json) => CacheItem(
    data: json['data'],
    timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    ttl: json['ttl'] != null ? Duration(milliseconds: json['ttl']) : null,
  );
}