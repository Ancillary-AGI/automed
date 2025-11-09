import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity connectivity;

  ConnectivityService(this.connectivity);

  Stream<List<ConnectivityResult>> get connectivityStream {
    return connectivity.onConnectivityChanged.map((result) => [result]);
  }

  Future<List<ConnectivityResult>> get currentConnectivity async {
    final result = await connectivity.checkConnectivity();
    return [result];
  }

  Future<bool> get isConnected async {
    final results = await currentConnectivity;
    return results.any((result) => result != ConnectivityResult.none);
  }

  Future<bool> get isWifi async {
    final results = await currentConnectivity;
    return results.contains(ConnectivityResult.wifi);
  }

  Future<bool> get isMobile async {
    final results = await currentConnectivity;
    return results.contains(ConnectivityResult.mobile);
  }

  Future<bool> get isEthernet async {
    final results = await currentConnectivity;
    return results.contains(ConnectivityResult.ethernet);
  }

  Future<bool> get isBluetooth async {
    final results = await currentConnectivity;
    return results.contains(ConnectivityResult.bluetooth);
  }

  Future<bool> get isVpn async {
    final results = await currentConnectivity;
    return results.contains(ConnectivityResult.vpn);
  }

  Future<bool> get isOther async {
    final results = await currentConnectivity;
    return results.contains(ConnectivityResult.other);
  }

  Future<String> getConnectionType() async {
    final results = await currentConnectivity;
    if (results.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (results.contains(ConnectivityResult.mobile)) {
      return 'Mobile';
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else if (results.contains(ConnectivityResult.bluetooth)) {
      return 'Bluetooth';
    } else if (results.contains(ConnectivityResult.vpn)) {
      return 'VPN';
    } else if (results.contains(ConnectivityResult.other)) {
      return 'Other';
    } else {
      return 'None';
    }
  }

  Future<Map<String, dynamic>> getConnectivityInfo() async {
    final results = await currentConnectivity;
    final isConnected = await this.isConnected;

    return {
      'isConnected': isConnected,
      'connectionType': await getConnectionType(),
      'connectivityResults': results.map((r) => r.name).toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
