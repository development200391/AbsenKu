import 'package:dio/dio.dart';

import '../../../core/api_client.dart';
import '../models/attendance_models.dart';

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AttendanceRepository {
  AttendanceRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AttendanceRecord?> getToday() async {
    final response = await _run(() => _apiClient.dio.get('/hr/attendance/self/today'));
    if (response.data == null || response.data == '') {
      return null;
    }
    return AttendanceRecord.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<AttendanceRecord>> getHistory({DateTime? from, DateTime? to}) async {
    final response = await _run(() => _apiClient.dio.get('/hr/attendance/self/history', queryParameters: {
          if (from != null) 'from': _formatDate(from),
          if (to != null) 'to': _formatDate(to),
        }));
    final items = response.data as List<dynamic>;
    return items.map((item) => AttendanceRecord.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<AttendanceSettings> getSettings() async {
    final response = await _run(() => _apiClient.dio.get('/hr/attendance/settings'));
    return AttendanceSettings.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DateTime> getServerTime() async {
    final response = await _run(() => _apiClient.dio.get('/diagnostics/server-time'));
    final data = response.data as Map<String, dynamic>;
    return DateTime.parse(data['serverTime'] as String).toLocal();
  }

  Future<AttendanceRecord> checkIn({required double latitude, required double longitude}) async {
    final response = await _run(() => _apiClient.dio.post('/hr/attendance/self/check-in', data: {
          'latitude': latitude,
          'longitude': longitude,
        }));
    return AttendanceRecord.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AttendanceRecord> checkOut({required double latitude, required double longitude}) async {
    final response = await _run(() => _apiClient.dio.post('/hr/attendance/self/check-out', data: {
          'latitude': latitude,
          'longitude': longitude,
        }));
    return AttendanceRecord.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AttendanceRecord> markStatus({
    required DateTime date,
    required AttendanceStatus status,
    String? notes,
  }) async {
    final response = await _run(() => _apiClient.dio.post('/hr/attendance/self/mark', data: {
          'date': _formatDate(date),
          'status': status.value,
          'notes': notes,
        }));
    return AttendanceRecord.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Response> _run(Future<Response> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e) ?? 'Terjadi kesalahan. Coba lagi.');
    }
  }

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String? _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return null;
  }
}
