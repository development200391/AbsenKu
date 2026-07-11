import 'package:dio/dio.dart';

/// A request failed with a message returned by the backend. [message]
/// originates server-side (currently always Indonesian/English as written by
/// the API) and is shown to the user as-is, untranslated.
class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// A request failed because the device couldn't reach the server at all
/// (no network, DNS failure, timeout). Client-side and translatable.
class ConnectionException implements Exception {
  const ConnectionException();
}

/// A request failed but the backend didn't return a usable error message.
/// Client-side and translatable.
class UnknownApiException implements Exception {
  const UnknownApiException();
}

/// Maps a [DioException] to one of [ConnectionException], [ApiException], or
/// [UnknownApiException] so screens can pick a localized message by type.
Exception mapDioException(DioException e) {
  if (_isConnectionFailure(e)) {
    return const ConnectionException();
  }

  final message = _extractErrorMessage(e);
  if (message != null) {
    return ApiException(message);
  }

  return const UnknownApiException();
}

bool _isConnectionFailure(DioException e) {
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

String? _extractErrorMessage(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['message'] is String) {
    return data['message'] as String;
  }
  return null;
}
