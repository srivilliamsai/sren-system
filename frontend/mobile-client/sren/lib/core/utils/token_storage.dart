import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage(this._secureStorage);

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _profileKey = 'user_profile';

  final FlutterSecureStorage _secureStorage;

  String? _cachedAccessToken;
  String? _cachedRefreshToken;
  Map<String, dynamic>? _cachedProfile;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken;
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<void> saveProfile(Map<String, dynamic> profile) async {
    _cachedProfile = profile;
    await _secureStorage.write(
      key: _profileKey,
      value: jsonEncode(profile),
    );
  }

  Future<String?> readAccessToken() async {
    _cachedAccessToken ??=
        await _secureStorage.read(key: _accessTokenKey);
    return _cachedAccessToken;
  }

  Future<String?> readRefreshToken() async {
    _cachedRefreshToken ??=
        await _secureStorage.read(key: _refreshTokenKey);
    return _cachedRefreshToken;
  }

  Future<Map<String, dynamic>?> readProfile() async {
    if (_cachedProfile != null) {
      return _cachedProfile;
    }
    final raw = await _secureStorage.read(key: _profileKey);
    if (raw == null) {
      return null;
    }
    return _cachedProfile = jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clear() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _cachedProfile = null;
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _profileKey),
    ]);
  }
}
