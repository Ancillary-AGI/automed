import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../models/api_response.dart';
import 'api_service.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage;
  final ApiService _apiService;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  AuthService(this._secureStorage, this._apiService);

  // Authentication methods
  Future<AuthResult> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiService.login(request);
      
      if (response.success && response.data != null) {
        await _storeTokens(response.data!);
        return AuthResult.success(response.data!.user);
      } else {
        return AuthResult.failure(response.message ?? 'Login failed');
      }
    } catch (e) {
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String userType,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        userType: userType,
        additionalData: additionalData,
      );
      
      final response = await _apiService.register(request);
      
      if (response.success && response.data != null) {
        await _storeTokens(response.data!);
        return AuthResult.success(response.data!.user);
      } else {
        return AuthResult.failure(response.message ?? 'Registration failed');
      }
    } catch (e) {
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken == null) return false;

      final request = RefreshTokenRequest(refreshToken: refreshToken);
      final response = await _apiService.refreshToken(request);
      
      if (response.success && response.data != null) {
        await _storeTokens(response.data!);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Continue with local logout even if API call fails
    } finally {
      await _clearTokens();
    }
  }

  // Token management
  Future<String?> getAccessToken() async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    if (token != null && !JwtDecoder.isExpired(token)) {
      return token;
    }
    
    // Try to refresh token if expired
    if (token != null && JwtDecoder.isExpired(token)) {
      final refreshed = await refreshToken();
      if (refreshed) {
        return await _secureStorage.read(key: _accessTokenKey);
      }
    }
    
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }

  Future<User?> getCurrentUser() async {
    final userData = await _secureStorage.read(key: _userDataKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<String?> getUserType() async {
    final user = await getCurrentUser();
    return user?.userType;
  }

  Future<String?> getUserId() async {
    final user = await getCurrentUser();
    return user?.id;
  }

  // Biometric authentication
  Future<bool> isBiometricEnabled() async {
    final enabled = await _secureStorage.read(key: 'biometric_enabled');
    return enabled == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(key: 'biometric_enabled', value: enabled.toString());
  }

  Future<bool> authenticateWithBiometrics() async {
    // This would integrate with local_auth package
    // For now, return false as placeholder
    return false;
  }

  // Private methods
  Future<void> _storeTokens(AuthResponse authResponse) async {
    await _secureStorage.write(key: _accessTokenKey, value: authResponse.accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: authResponse.refreshToken);
    await _secureStorage.write(key: _userDataKey, value: jsonEncode(authResponse.user.toJson()));
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _userDataKey);
  }

  // Token validation
  bool isTokenValid(String token) {
    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic>? decodeToken(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      return null;
    }
  }
}

// Data classes
class AuthResult {
  final bool success;
  final User? user;
  final String? error;

  AuthResult.success(this.user) : success = true, error = null;
  AuthResult.failure(this.error) : success = false, user = null;
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class RegisterRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String userType;
  final Map<String, dynamic>? additionalData;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.userType,
    this.additionalData,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'firstName': firstName,
    'lastName': lastName,
    'userType': userType,
    if (additionalData != null) ...additionalData!,
  };
}

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {
    'refreshToken': refreshToken,
  };
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    accessToken: json['accessToken'],
    refreshToken: json['refreshToken'],
    user: User.fromJson(json['user']),
  );
}

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String userType;
  final Map<String, dynamic>? profile;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.userType,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    email: json['email'],
    firstName: json['firstName'],
    lastName: json['lastName'],
    userType: json['userType'],
    profile: json['profile'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'userType': userType,
    if (profile != null) 'profile': profile,
  };

  String get fullName => '$firstName $lastName';
}