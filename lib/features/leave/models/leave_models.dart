import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';

enum LeaveStatus {
  pending(0),
  approved(1),
  rejected(2);

  const LeaveStatus(this.value);

  final int value;

  static LeaveStatus fromValue(int value) {
    return LeaveStatus.values.firstWhere((status) => status.value == value, orElse: () => LeaveStatus.pending);
  }

  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case LeaveStatus.pending:
        return l10n.leaveStatusPending;
      case LeaveStatus.approved:
        return l10n.leaveStatusApproved;
      case LeaveStatus.rejected:
        return l10n.leaveStatusRejected;
    }
  }
}

class LeaveType {
  LeaveType({required this.id, required this.name});

  factory LeaveType.fromJson(Map<String, dynamic> json) {
    return LeaveType(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  final int id;
  final String name;
}

class LeaveRequest {
  LeaveRequest({
    required this.id,
    required this.leaveTypeId,
    required this.leaveTypeName,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    required this.status,
    required this.approvedByName,
    required this.createdAt,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'] as int,
      leaveTypeId: json['leaveTypeId'] as int,
      leaveTypeName: json['leaveTypeName'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalDays: json['totalDays'] as int,
      reason: json['reason'] as String?,
      status: LeaveStatus.fromValue(json['status'] as int),
      approvedByName: json['approvedByName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }

  final int id;
  final int leaveTypeId;
  final String leaveTypeName;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String? reason;
  final LeaveStatus status;
  final String? approvedByName;
  final DateTime createdAt;
}

class LeaveDocument {
  LeaveDocument({
    required this.id,
    required this.originalFileName,
    required this.fileSizeBytes,
    required this.categoryName,
    required this.description,
    required this.uploadedByName,
    required this.uploadedAt,
  });

  factory LeaveDocument.fromJson(Map<String, dynamic> json) {
    return LeaveDocument(
      id: json['id'] as int,
      originalFileName: json['originalFileName'] as String,
      fileSizeBytes: json['fileSizeBytes'] as int,
      categoryName: json['categoryName'] as String?,
      description: json['description'] as String?,
      uploadedByName: json['uploadedByName'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String).toLocal(),
    );
  }

  final int id;
  final String originalFileName;
  final int fileSizeBytes;
  final String? categoryName;
  final String? description;
  final String uploadedByName;
  final DateTime uploadedAt;
}
