import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  StreamController<ConnectivityStatus>? _connectivityController;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;
  
  Stream<ConnectivityStatus> get connectivityStream {
    _connectivityController ??= StreamController<ConnectivityStatus>.broadcast();
    return _connectivityController!.stream;
  }

  ConnectivityStatus get currentStatus => _currentStatus;

  bool get isConnected => _currentStatus == ConnectivityStatus.connected;
  bool get isDisconnected => _currentStatus == ConnectivityStatus.disconnected;

  Future<void> initialize() async {
    // Check initial connectivity
    await _updateConnectivityStatus();
    
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        await _updateConnectivityStatus();
      },
    );
  }

  Future<void> _updateConnectivityStatus() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final hasInternet = await _hasInternetConnection();
      
      ConnectivityStatus newStatus;
      
      if (connectivityResult == ConnectivityResult.none) {
        newStatus = ConnectivityStatus.disconnected;
      } else if (hasInternet) {
        newStatus = ConnectivityStatus.connected;
      } else {
        newStatus = ConnectivityStatus.limited;
      }
      
      if (newStatus != _currentStatus) {
        _currentStatus = newStatus;
        _connectivityController?.add(_currentStatus);
      }
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      _currentStatus = ConnectivityStatus.unknown;
      _connectivityController?.add(_currentStatus);
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      debugPrint('Error checking internet connection: $e');
      return false;
    }
  }

  Future<ConnectivityResult> getConnectivityResult() async {
    return await _connectivity.checkConnectivity();
  }

  Future<bool> hasInternetConnection() async {
    final connectivityResult = await getConnectivityResult();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return await _hasInternetConnection();
  }

  Future<NetworkInfo> getNetworkInfo() async {
    final connectivityResult = await getConnectivityResult();
    final hasInternet = await _hasInternetConnection();
    
    return NetworkInfo(
      connectivityResult: connectivityResult,
      hasInternet: hasInternet,
      status: _currentStatus,
    );
  }

  // Check if specific host is reachable
  Future<bool> canReachHost(String host, {int port = 80, Duration timeout = const Duration(seconds: 5)}) async {
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check API server connectivity
  Future<bool> canReachApiServer(String apiBaseUrl) async {
    try {
      final uri = Uri.parse(apiBaseUrl);
      final host = uri.host;
      final port = uri.port != 0 ? uri.port : (uri.scheme == 'https' ? 443 : 80);
      
      return await canReachHost(host, port: port);
    } catch (e) {
      debugPrint('Error checking API server connectivity: $e');
      return false;
    }
  }

  // Network quality assessment
  Future<NetworkQuality> assessNetworkQuality() async {
    if (!isConnected) {
      return NetworkQuality.none;
    }

    try {
      final stopwatch = Stopwatch()..start();
      final result = await InternetAddress.lookup('google.com');
      stopwatch.stop();
      
      if (result.isEmpty) {
        return NetworkQuality.poor;
      }
      
      final latency = stopwatch.elapsedMilliseconds;
      
      if (latency < 100) {
        return NetworkQuality.excellent;
      } else if (latency < 300) {
        return NetworkQuality.good;
      } else if (latency < 1000) {
        return NetworkQuality.fair;
      } else {
        return NetworkQuality.poor;
      }
    } catch (e) {
      return NetworkQuality.poor;
    }
  }

  // Bandwidth estimation (simplified)
  Future<double> estimateBandwidth() async {
    if (!isConnected) return 0.0;
    
    try {
      // This is a simplified bandwidth test
      // In a real implementation, you might download a small file and measure the time
      final stopwatch = Stopwatch()..start();
      await InternetAddress.lookup('google.com');
      stopwatch.stop();
      
      // Very rough estimation based on DNS lookup time
      final latency = stopwatch.elapsedMilliseconds;
      if (latency < 50) return 10.0; // Assume high-speed connection
      if (latency < 100) return 5.0; // Assume medium-speed connection
      if (latency < 500) return 1.0; // Assume low-speed connection
      return 0.1; // Very slow connection
    } catch (e) {
      return 0.0;
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController?.close();
  }
}

enum ConnectivityStatus {
  connected,
  disconnected,
  limited, // Connected but no internet
  unknown,
}

enum NetworkQuality {
  none,
  poor,
  fair,
  good,
  excellent,
}

class NetworkInfo {
  final ConnectivityResult connectivityResult;
  final bool hasInternet;
  final ConnectivityStatus status;

  NetworkInfo({
    required this.connectivityResult,
    required this.hasInternet,
    required this.status,
  });

  String get connectionType {
    switch (connectivityResult) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'No Connection';
    }
  }

  bool get isWifi => connectivityResult == ConnectivityResult.wifi;
  bool get isMobile => connectivityResult == ConnectivityResult.mobile;
  bool get isEthernet => connectivityResult == ConnectivityResult.ethernet;
}