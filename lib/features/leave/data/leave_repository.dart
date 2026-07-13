import 'package:dio/dio.dart';

import '../../../core/api_client.dart';
import '../../../core/api_exception.dart';
import '../models/leave_models.dart';

class LeaveRepository {
  LeaveRepository(this._apiClient);

  final ApiClient _apiClient;

  static const _referenceType = 'hr_leave_requests';

  Future<List<LeaveType>> getLeaveTypes() async {
    final response = await _run(() => _apiClient.dio.get('/hr/leave-requests/self/leave-types'));
    final items = response.data as List<dynamic>;
    return items.map((item) => LeaveType.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<DocumentReferenceTypeConfig?> getAttachmentConfig() async {
    try {
      final response = await _apiClient.dio.get(
        '/documents/config',
        queryParameters: {'referenceType': _referenceType},
      );
      return DocumentReferenceTypeConfig.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw mapDioException(e);
    }
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

  Future<List<LeaveDocument>> getAttachments(int leaveRequestId) async {
    final response = await _run(() => _apiClient.dio.get('/documents', queryParameters: {
          'referenceType': _referenceType,
          'referenceId': leaveRequestId,
        }));
    final items = response.data as List<dynamic>;
    return items.map((item) => LeaveDocument.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Submits the leave request and every attachment slot together in a
  /// single request. The server creates the leave request first and then
  /// attaches each file to it, so a rejected/corrupt file never leaves an
  /// orphaned upload behind and a required-attachment rule can be enforced
  /// before anything is saved at all.
  ///
  /// [slots] must have one entry per active `DocumentReferenceTypeConfigDetail`,
  /// in the same order — including empty entries (bytes: null) for slots the
  /// user left blank. Every slot always sends a `Files` part (empty when
  /// unset) and a positionally-matching `Notes[i]` part, because the server
  /// tells "slot i has no attachment" apart from "slot i has no *new*
  /// attachment" purely by that positional alignment (see
  /// ReadMeDocumentGeneral.md, "Integrasi Web" — the same alignment
  /// requirement the Web client has to honor).
  Future<SubmitLeaveRequestResult> submit({
    required int leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
    List<({List<int>? bytes, String? fileName, String? note})> slots = const [],
  }) async {
    final formData = FormData();
    formData.fields.addAll([
      MapEntry('LeaveTypeId', leaveTypeId.toString()),
      MapEntry('StartDate', _formatDate(startDate)),
      MapEntry('EndDate', _formatDate(endDate)),
      if (reason != null) MapEntry('Reason', reason),
    ]);

    for (var i = 0; i < slots.length; i++) {
      final slot = slots[i];
      formData.files.add(MapEntry(
        'Files',
        slot.bytes != null
            ? MultipartFile.fromBytes(slot.bytes!, filename: slot.fileName ?? 'file')
            : MultipartFile.fromBytes(const <int>[], filename: ''),
      ));
      formData.fields.add(MapEntry('Notes[$i]', slot.note ?? ''));
    }

    final response = await _run(() => _apiClient.dio.post('/hr/leave-requests/self', data: formData));
    return SubmitLeaveRequestResult.fromJson(response.data as Map<String, dynamic>);
  }

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
