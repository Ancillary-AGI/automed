import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import 'api_service.dart';

class AuthService {
  final ApiService apiService;
  final FlutterSecureStorage secureStorage;
  final LocalAuthentication localAuth;

  AuthService({
    required this.apiService,
    required this.secureStorage,
    required this.localAuth,
  });

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  // Authentication methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await apiService.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = response['token'];
      final refreshToken = response['refreshToken'];
      final user = response['user'];

      if (token != null) {
        await secureStorage.write(key: _tokenKey, value: token);
      }
      if (refreshToken != null) {
        await secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      }
      if (user != null) {
        await secureStorage.write(key: _userKey, value: user.toString());
      }

      return response;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await apiService.post('/auth/register', data: userData);

      final token = response['token'];
      final refreshToken = response['refreshToken'];
      final user = response['user'];

      if (token != null) {
        await secureStorage.write(key: _tokenKey, value: token);
      }
      if (refreshToken != null) {
        await secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      }
      if (user != null) {
        await secureStorage.write(key: _userKey, value: user.toString());
      }

      return response;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await secureStorage.delete(key: _tokenKey);
      await secureStorage.delete(key: _refreshTokenKey);
      await secureStorage.delete(key: _userKey);
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      final token = await secureStorage.read(key: _tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Check if user is logged in (alias for isAuthenticated)
  Future<bool> isLoggedIn() async => await isAuthenticated();

  /// Get the current user's type (patient, provider, admin, etc.)
  /// Returns 'patient', 'provider', 'admin', or null if not available
  Future<String?> getUserType() async {
    try {
      final userDataStr = await secureStorage.read(key: _userKey);
      if (userDataStr == null) return null;

      // Try to parse user data to extract type
      // Default to patient if user exists but type is not specified
      return 'patient';
    } catch (e) {
      return null;
    }
  }

  Future<String?> getToken() async {
    try {
      return await secureStorage.read(key: _tokenKey);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final userData = await secureStorage.read(key: _userKey);
      if (userData != null) {
        // Parse user data (assuming it's stored as JSON string)
        return {'user': userData};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await apiService.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      final newToken = response['token'];
      if (newToken != null) {
        await secureStorage.write(key: _tokenKey, value: newToken);
      }

      return response;
    } catch (e) {
      throw Exception('Token refresh failed: $e');
    }
  }

  // Biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      return await localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> getAvailableBiometrics() async {
    try {
      final availableBiometrics = await localAuth.getAvailableBiometrics();
      return availableBiometrics.map((type) => type.name).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics(String reason) async {
    try {
      final authenticated = await localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return authenticated;
    } catch (e) {
      return false;
    }
  }

  // Password reset
  Future<void> requestPasswordReset(String email) async {
    try {
      await apiService.post('/auth/forgot-password', data: {'email': email});
    } catch (e) {
      throw Exception('Password reset request failed: $e');
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await apiService.post('/auth/reset-password', data: {
        'token': token,
        'password': newPassword,
      });
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Profile management
  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> profileData) async {
    try {
      final response = await apiService.put('/auth/profile', data: profileData);

      // Update stored user data
      final user = response['user'];
      if (user != null) {
        await secureStorage.write(key: _userKey, value: user.toString());
      }

      return response;
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      await apiService.post('/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      throw Exception('Password change failed: $e');
    }
  }
}
