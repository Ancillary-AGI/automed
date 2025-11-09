import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  final Box<dynamic> box;

  CacheService(this.box);

  // Generic cache operations
  Future<void> put(String key, dynamic value) async {
    await box.put(key, value);
  }

  dynamic get(String key) {
    return box.get(key);
  }

  Future<void> delete(String key) async {
    await box.delete(key);
  }

  Future<void> clear() async {
    await box.clear();
  }

  bool containsKey(String key) {
    return box.containsKey(key);
  }

  // Patient data caching
  Future<void> cachePatientData(String patientId, Map<String, dynamic> data) async {
    await put('patient_$patientId', data);
  }

  Map<String, dynamic>? getCachedPatientData(String patientId) {
    return get('patient_$patientId') as Map<String, dynamic>?;
  }

  // Dashboard data caching
  Future<void> cacheDashboardData(Map<String, dynamic> data) async {
    await put('dashboard_data', data);
    await put('dashboard_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  Map<String, dynamic>? getCachedDashboardData() {
    final data = get('dashboard_data') as Map<String, dynamic>?;
    final timestamp = get('dashboard_timestamp') as int?;

    if (data != null && timestamp != null) {
      // Check if data is still fresh (less than 5 minutes old)
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age < 5 * 60 * 1000) { // 5 minutes
        return data;
      }
    }
    return null;
  }

  // Medication data caching
  Future<void> cacheMedications(List<Map<String, dynamic>> medications) async {
    await put('medications', medications);
    await put('medications_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  List<Map<String, dynamic>>? getCachedMedications() {
    final medications = get('medications') as List<Map<String, dynamic>>?;
    final timestamp = get('medications_timestamp') as int?;

    if (medications != null && timestamp != null) {
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age < 10 * 60 * 1000) { // 10 minutes
        return medications;
      }
    }
    return null;
  }

  // Appointments caching
  Future<void> cacheAppointments(List<Map<String, dynamic>> appointments) async {
    await put('appointments', appointments);
    await put('appointments_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  List<Map<String, dynamic>>? getCachedAppointments() {
    final appointments = get('appointments') as List<Map<String, dynamic>>?;
    final timestamp = get('appointments_timestamp') as int?;

    if (appointments != null && timestamp != null) {
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age < 15 * 60 * 1000) { // 15 minutes
        return appointments;
      }
    }
    return null;
  }

  // Hospital data caching
  Future<void> cacheHospitals(List<Map<String, dynamic>> hospitals) async {
    await put('hospitals', hospitals);
    await put('hospitals_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  List<Map<String, dynamic>>? getCachedHospitals() {
    final hospitals = get('hospitals') as List<Map<String, dynamic>>?;
    final timestamp = get('hospitals_timestamp') as int?;

    if (hospitals != null && timestamp != null) {
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age < 30 * 60 * 1000) { // 30 minutes
        return hospitals;
      }
    }
    return null;
  }

  // Analytics data caching
  Future<void> cacheAnalyticsData(Map<String, dynamic> analytics) async {
    await put('analytics_data', analytics);
    await put('analytics_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  Map<String, dynamic>? getCachedAnalyticsData() {
    final analytics = get('analytics_data') as Map<String, dynamic>?;
    final timestamp = get('analytics_timestamp') as int?;

    if (analytics != null && timestamp != null) {
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age < 60 * 60 * 1000) { // 1 hour
        return analytics;
      }
    }
    return null;
  }

  // User preferences caching
  Future<void> cacheUserPreferences(Map<String, dynamic> preferences) async {
    await put('user_preferences', preferences);
  }

  Map<String, dynamic>? getCachedUserPreferences() {
    return get('user_preferences') as Map<String, dynamic>?;
  }

  // Offline queue caching
  Future<void> cacheOfflineQueue(List<Map<String, dynamic>> queue) async {
    await put('offline_queue', queue);
  }

  List<Map<String, dynamic>> getCachedOfflineQueue() {
    return get('offline_queue') as List<Map<String, dynamic>>? ?? [];
  }

  Future<void> addToOfflineQueue(Map<String, dynamic> item) async {
    final queue = getCachedOfflineQueue();
    queue.add(item);
    await cacheOfflineQueue(queue);
  }

  Future<void> removeFromOfflineQueue(int index) async {
    final queue = getCachedOfflineQueue();
    if (index >= 0 && index < queue.length) {
      queue.removeAt(index);
      await cacheOfflineQueue(queue);
    }
  }

  // Cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'total_keys': box.length,
      'keys': box.keys.toList(),
      'is_empty': box.isEmpty,
      'is_not_empty': box.isNotEmpty,
    };
  }

  // Clear specific cache types
  Future<void> clearPatientCache() async {
    final keysToDelete = box.keys.where((key) => key.toString().startsWith('patient_'));
    for (final key in keysToDelete) {
      await delete(key);
    }
  }

  Future<void> clearExpiredCache() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final keysWithTimestamps = [
      'dashboard_timestamp',
      'medications_timestamp',
      'appointments_timestamp',
      'hospitals_timestamp',
      'analytics_timestamp',
    ];

    for (final timestampKey in keysWithTimestamps) {
      final timestamp = get(timestampKey) as int?;
      if (timestamp != null) {
        final age = now - timestamp;
        final maxAge = _getMaxAgeForKey(timestampKey);
        if (age > maxAge) {
          // Delete the data and timestamp
          final dataKey = timestampKey.replaceAll('_timestamp', '_data');
          await delete(dataKey);
          await delete(timestampKey);
        }
      }
    }
  }

  int _getMaxAgeForKey(String key) {
    switch (key) {
      case 'dashboard_timestamp':
        return 5 * 60 * 1000; // 5 minutes
      case 'medications_timestamp':
        return 10 * 60 * 1000; // 10 minutes
      case 'appointments_timestamp':
        return 15 * 60 * 1000; // 15 minutes
      case 'hospitals_timestamp':
        return 30 * 60 * 1000; // 30 minutes
      case 'analytics_timestamp':
        return 60 * 60 * 1000; // 1 hour
      default:
        return 60 * 60 * 1000; // 1 hour default
    }
  }
}