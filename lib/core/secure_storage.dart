import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  const SecureStorageService();

  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _localeCodeKey = 'locale_code';

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  /// The user's chosen app language, persisted independently from the auth
  /// session (a logout must not reset the language back to system default).
  Future<String?> getLocaleCode() => _storage.read(key: _localeCodeKey);

  Future<void> saveLocaleCode(String? code) async {
    if (code == null) {
      await _storage.delete(key: _localeCodeKey);
    } else {
      await _storage.write(key: _localeCodeKey, value: code);
    }
  }
}
