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
    required this.description,
    required this.uploadedByName,
    required this.uploadedAt,
  });

  factory LeaveDocument.fromJson(Map<String, dynamic> json) {
    return LeaveDocument(
      id: json['id'] as int,
      originalFileName: json['originalFileName'] as String,
      fileSizeBytes: json['fileSizeBytes'] as int,
      description: json['description'] as String?,
      uploadedByName: json['uploadedByName'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String).toLocal(),
    );
  }

  final int id;
  final String originalFileName;
  final int fileSizeBytes;
  final String? description;
  final String uploadedByName;
  final DateTime uploadedAt;
}

class SubmitLeaveRequestResult {
  SubmitLeaveRequestResult({required this.leaveRequest, required this.attachmentWarnings});

  factory SubmitLeaveRequestResult.fromJson(Map<String, dynamic> json) {
    return SubmitLeaveRequestResult(
      leaveRequest: LeaveRequest.fromJson(json['leaveRequest'] as Map<String, dynamic>),
      attachmentWarnings: (json['attachmentWarnings'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),
    );
  }

  final LeaveRequest leaveRequest;
  final List<String> attachmentWarnings;
}

/// One row per attachment slot the module defines (e.g. "KTP", "Surat
/// Keterangan Dokter") — mirrors doc_reference_type_config_details on the
/// server. Each slot gets its own file picker and note in the UI.
class DocumentReferenceTypeConfigDetail {
  DocumentReferenceTypeConfigDetail({
    required this.name,
    required this.isRequired,
    required this.isActive,
    required this.maxFileSizeBytes,
    required this.allowedExtensions,
  });

  factory DocumentReferenceTypeConfigDetail.fromJson(Map<String, dynamic> json) {
    final extensionsRaw = json['allowedExtensions'] as String?;
    return DocumentReferenceTypeConfigDetail(
      name: json['name'] as String,
      isRequired: json['isRequired'] as bool,
      isActive: json['isActive'] as bool,
      maxFileSizeBytes: json['maxFileSizeBytes'] as int?,
      allowedExtensions: (extensionsRaw == null || extensionsRaw.trim().isEmpty)
          ? const ['.pdf', '.jpg', '.jpeg', '.png', '.docx']
          : extensionsRaw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
    );
  }

  final String name;
  final bool isRequired;
  final bool isActive;
  final int? maxFileSizeBytes;
  final List<String> allowedExtensions;
}

class DocumentReferenceTypeConfig {
  DocumentReferenceTypeConfig({
    required this.displayName,
    required this.isMultiple,
    required this.maxFileCount,
    required this.details,
  });

  factory DocumentReferenceTypeConfig.fromJson(Map<String, dynamic> json) {
    final detailsRaw = json['details'] as List<dynamic>? ?? [];
    return DocumentReferenceTypeConfig(
      displayName: json['displayName'] as String,
      isMultiple: json['isMultiple'] as bool,
      maxFileCount: json['maxFileCount'] as int,
      details: detailsRaw
          .map((item) => DocumentReferenceTypeConfigDetail.fromJson(item as Map<String, dynamic>))
          .where((detail) => detail.isActive)
          .toList(),
    );
  }

  final String displayName;
  final bool isMultiple;
  final int maxFileCount;
  final List<DocumentReferenceTypeConfigDetail> details;
}
