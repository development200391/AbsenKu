import 'package:dio/dio.dart';

import '../../../core/api_client.dart';
import '../../../core/api_exception.dart';
import '../models/leave_models.dart';

class LeaveRepository {
  LeaveRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<LeaveType>> getLeaveTypes() async {
    final response = await _run(() => _apiClient.dio.get('/hr/leave-requests/self/leave-types'));
    final items = response.data as List<dynamic>;
    return items.map((item) => LeaveType.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<LeaveRequest>> getHistory() async {
    final response = await _run(() => _apiClient.dio.get('/hr/leave-requests/self', queryParameters: {
          'page': 1,
          'pageSize': 100,
        }));
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;
    return items.map((item) => LeaveRequest.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<LeaveRequest> submit({
    required int leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  }) async {
    final response = await _run(() => _apiClient.dio.post('/hr/leave-requests/self', data: {
          'leaveTypeId': leaveTypeId,
          'startDate': _formatDate(startDate),
          'endDate': _formatDate(endDate),
          'reason': reason,
        }));
    return LeaveRequest.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<LeaveDocument>> getAttachments(int leaveRequestId) async {
    final response = await _run(() => _apiClient.dio.get('/documents', queryParameters: {
          'referenceType': _referenceType,
          'referenceId': leaveRequestId,
        }));
    final items = response.data as List<dynamic>;
    return items.map((item) => LeaveDocument.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<LeaveDocument> uploadAttachment({
    required int leaveRequestId,
    required List<int> bytes,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'referenceType': _referenceType,
      'referenceId': leaveRequestId,
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });

    final response = await _run(() => _apiClient.dio.post('/documents', data: formData));
    return LeaveDocument.fromJson(response.data as Map<String, dynamic>);
  }

  static const _referenceType = 'hr_leave_requests';

  Future<Response> _run(Future<Response> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
