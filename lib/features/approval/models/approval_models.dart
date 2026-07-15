enum ApprovalRequestStatus {
  pending(0),
  inProgress(1),
  approved(2),
  rejected(3),
  cancelled(4),
  expired(5);

  const ApprovalRequestStatus(this.value);

  final int value;

  static ApprovalRequestStatus fromValue(int value) {
    return ApprovalRequestStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ApprovalRequestStatus.pending,
    );
  }
}

class ApprovalDashboard {
  ApprovalDashboard({required this.waitingMyActionCount});

  factory ApprovalDashboard.fromJson(Map<String, dynamic> json) {
    return ApprovalDashboard(
      waitingMyActionCount: json['waitingMyActionCount'] as int? ?? 0,
    );
  }

  final int waitingMyActionCount;
}

/// One row in the current user's Approval Inbox — mirrors ApprovalInboxDto
/// on the server (ERP.Application/DTOs/Approval/ApprovalDtos.cs), already
/// scoped to the logged-in user's active steps across every module wired
/// into General Approval (currently just hr_leave_requests).
class ApprovalInboxItem {
  ApprovalInboxItem({
    required this.requestId,
    required this.stepId,
    required this.requestNo,
    required this.subject,
    required this.module,
    required this.referenceType,
    required this.referenceId,
    required this.requestedByName,
    required this.requestedAt,
    required this.dueAt,
    required this.isOverdue,
    required this.status,
  });

  factory ApprovalInboxItem.fromJson(Map<String, dynamic> json) {
    return ApprovalInboxItem(
      requestId: json['requestId'] as int,
      stepId: json['stepId'] as int,
      requestNo: json['requestNo'] as String,
      subject: json['subject'] as String,
      module: json['module'] as String,
      referenceType: json['referenceType'] as String,
      referenceId: json['referenceId'] as int,
      requestedByName: json['requestedByName'] as String,
      requestedAt: DateTime.parse(json['requestedAt'] as String).toLocal(),
      dueAt: DateTime.parse(json['dueAt'] as String).toLocal(),
      isOverdue: json['isOverdue'] as bool,
      status: ApprovalRequestStatus.fromValue(json['status'] as int),
    );
  }

  final int requestId;
  final int stepId;
  final String requestNo;
  final String subject;
  final String module;
  final String referenceType;
  final int referenceId;
  final String requestedByName;
  final DateTime requestedAt;
  final DateTime dueAt;
  final bool isOverdue;
  final ApprovalRequestStatus status;
}
