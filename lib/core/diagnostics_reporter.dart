import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_config.dart';
import 'correlation.dart';

/// Best-effort reporter for uncaught app errors. Posts to the same
/// ERP.API instance the app already talks to; RequestLoggingMiddleware there
/// captures the request body (and X-Correlation-Id) into the same log file
/// used for ordinary HTTP traffic, so nothing else needs to be wired up.
class DiagnosticsReporter {
  DiagnosticsReporter._();

  static final DiagnosticsReporter instance = DiagnosticsReporter._();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 5),
    sendTimeout: const Duration(seconds: 5),
  ));

  final Map<String, DateTime> _lastSentAt = {};
  static const Duration _cooldown = Duration(minutes: 5);

  void report(Object error, StackTrace? stack, {required String source}) {
    final signature = '$source:${error.runtimeType}:$error';
    final now = DateTime.now();
    final last = _lastSentAt[signature];
    if (last != null && now.difference(last) < _cooldown) {
      return;
    }
    _lastSentAt[signature] = now;

    unawaited(_send(error: error, stack: stack, source: source));
  }

  Future<void> _send({required Object error, required StackTrace? stack, required String source}) async {
    try {
      await _dio.post('/diagnostics/client-log', data: {
        'correlationId': CorrelationContext.generate(),
        'referenceCorrelationId': CorrelationContext.lastRequestId,
        'source': source,
        'message': error.toString(),
        'stackTrace': stack?.toString(),
        'platform': defaultTargetPlatform.name,
        'occurredAt': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Reporting is best-effort only; never let it crash the app further.
    }
  }
}
