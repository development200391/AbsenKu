import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_config.dart';
import 'secure_storage.dart';

/// Marks a request as not needing an Authorization header and not eligible
/// for the 401-triggered refresh-and-retry flow (login, refresh-token itself).
const skipAuthExtraKey = 'skipAuth';

class ApiClient {
  ApiClient(this._storage, {required this.onSessionExpired}) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    _plainDio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (options.extra[skipAuthExtraKey] != true) {
          final token = await _storage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final isAuthEndpoint = error.requestOptions.extra[skipAuthExtraKey] == true;
        if (error.response?.statusCode != 401 || isAuthEndpoint) {
          handler.next(error);
          return;
        }

        final refreshed = await _refreshToken();
        if (!refreshed) {
          await _storage.clear();
          onSessionExpired();
          handler.next(error);
          return;
        }

        try {
          final retryOptions = error.requestOptions;
          final newToken = await _storage.getAccessToken();
          retryOptions.headers['Authorization'] = 'Bearer $newToken';
          final response = await _dio.fetch(retryOptions);
          handler.resolve(response);
        } catch (_) {
          handler.next(error);
        }
      },
    ));
  }

  late final Dio _dio;
  late final Dio _plainDio;
  final SecureStorageService _storage;
  final VoidCallback onSessionExpired;
  Future<bool>? _refreshFuture;

  Dio get dio => _dio;

  Future<bool> _refreshToken() {
    return _refreshFuture ??= _doRefresh().whenComplete(() => _refreshFuture = null);
  }

  Future<bool> _doRefresh() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) {
      return false;
    }

    try {
      final response = await _plainDio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
        options: Options(extra: {skipAuthExtraKey: true}),
      );
      final data = response.data as Map<String, dynamic>;
      await _storage.saveTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
