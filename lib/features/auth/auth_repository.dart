import 'package:dio/dio.dart';

import '../../core/api_client.dart';
import '../../core/secure_storage.dart';

class AuthRepository {
  AuthRepository(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final SecureStorageService _storage;

  /// Returns null on success, or an error message on failure.
  Future<String?> login(String username, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {'username': username, 'password': password},
        options: Options(extra: {skipAuthExtraKey: true}),
      );
      final data = response.data as Map<String, dynamic>;
      await _storage.saveTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      return null;
    } on DioException catch (e) {
      if (_isConnectionFailure(e)) {
        return 'Gagal terhubung ke server. Periksa koneksi internet/jaringan Anda.';
      }
      return _extractErrorMessage(e) ?? 'Login gagal. Periksa username/password Anda.';
    }
  }

  static bool _isConnectionFailure(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      default:
        return false;
    }
  }

  Future<void> logout() async {
    final refreshToken = await _storage.getRefreshToken();
    try {
      await _apiClient.dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    } catch (_) {
      // Best-effort: proceed with local logout even if the network call fails.
    }
    await _storage.clear();
  }

  static String? _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return null;
  }
}
