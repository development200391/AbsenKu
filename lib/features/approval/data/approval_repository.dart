import 'package:dio/dio.dart';

import '../../../core/api_client.dart';
import '../../../core/api_exception.dart';
import '../models/approval_models.dart';

class ApprovalRepository {
  ApprovalRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApprovalDashboard> getDashboard() async {
    final response = await _run(() => _apiClient.dio.get('/approval/dashboard'));
    return ApprovalDashboard.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<ApprovalInboxItem>> getInbox({int page = 1, int pageSize = 50}) async {
    final response = await _run(() => _apiClient.dio.get('/approval/inbox', queryParameters: {
          'page': page,
          'pageSize': pageSize,
        }));
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;
    return items.map((item) => ApprovalInboxItem.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// No comment field is offered from mobile (matches the ERP.Web Approval
  /// Inbox's own plain confirm-only Approve/Reject) — if a future template
  /// requires one (`RequireCommentOnReject`), the server rejects with a
  /// message that surfaces via [ApiException] as-is.
  Future<void> approve(int requestId) async {
    await _run(() => _apiClient.dio.post('/approval/requests/$requestId/actions/approve', data: {}));
  }

  Future<void> reject(int requestId) async {
    await _run(() => _apiClient.dio.post('/approval/requests/$requestId/actions/reject', data: {}));
  }

  Future<Response> _run(Future<Response> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
