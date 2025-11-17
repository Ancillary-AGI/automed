import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundLocationService {
  static const String _emergencyActiveKey = 'emergency_active';
  static const String _lastLocationKey = 'last_location';

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'location_channel',
        initialNotificationTitle: 'Emergency Location Tracking',
        initialNotificationContent:
            'Tracking your location for emergency services',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // Start location tracking
    _startLocationTracking(service);
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    return true;
  }

  static Future<void> _startLocationTracking(ServiceInstance service) async {
    final prefs = await SharedPreferences.getInstance();

    // Check if emergency is active
    final emergencyActive = prefs.getBool(_emergencyActiveKey) ?? false;
    if (!emergencyActive) {
      service.stopSelf();
      return;
    }

    // Request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        service.stopSelf();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      service.stopSelf();
      return;
    }

    // Start listening to location changes
    final locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
      forceLocationManager: true,
      intervalDuration: const Duration(seconds: 30),
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) async {
        // Save location
        final locationData = '${position.latitude},${position.longitude}';
        await prefs.setString(_lastLocationKey, locationData);

        // Send location to emergency service (API call)
        await _sendLocationToEmergencyService(position);

        // Update notification
        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: 'Emergency Location Tracking',
            content:
                'Location updated: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
          );
        }
      },
      onError: (error) {
        print('Location error: $error');
      },
    );
  }

  static Future<void> _sendLocationToEmergencyService(Position position) async {
    try {
      // TODO: Implement actual API call to emergency-response-service
      // For now, just log the location update
      print(
          'Location update sent to emergency service: ${position.latitude}, ${position.longitude} at ${position.timestamp}');

      // In a real implementation, this would make an HTTP call:
      // final response = await http.post(
      //   Uri.parse('${ApiConfig.emergencyServiceUrl}/api/v1/emergency/location/update'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'latitude': position.latitude,
      //     'longitude': position.longitude,
      //     'timestamp': position.timestamp?.toIso8601String(),
      //     'accuracy': position.accuracy,
      //     'speed': position.speed,
      //   }),
      // );
    } catch (e) {
      print('Failed to send location to emergency service: $e');
    }
  }

  static Future<void> startEmergencyTracking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_emergencyActiveKey, true);

    final service = FlutterBackgroundService();
    await service.startService();
  }

  static Future<void> stopEmergencyTracking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_emergencyActiveKey, false);

    final service = FlutterBackgroundService();
    service.invoke('stopService');
  }

  static Future<String?> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastLocationKey);
  }
}
