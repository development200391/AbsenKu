enum AttendanceStatus {
  present(0),
  absent(1),
  late_(2),
  halfDay(3),
  sick(4),
  cuti(5);

  const AttendanceStatus(this.value);

  final int value;

  static AttendanceStatus fromValue(int value) {
    return AttendanceStatus.values.firstWhere((status) => status.value == value, orElse: () => AttendanceStatus.present);
  }

  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'Hadir';
      case AttendanceStatus.absent:
        return 'Absen';
      case AttendanceStatus.late_:
        return 'Terlambat';
      case AttendanceStatus.halfDay:
        return 'Setengah Hari';
      case AttendanceStatus.sick:
        return 'Sakit';
      case AttendanceStatus.cuti:
        return 'Cuti';
    }
  }
}

/// Statuses an employee may self-report via the "mark" endpoint.
const selfReportableStatuses = [
  AttendanceStatus.halfDay,
  AttendanceStatus.sick,
  AttendanceStatus.cuti,
  AttendanceStatus.absent,
];

class AttendanceRecord {
  AttendanceRecord({
    required this.id,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.notes,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as int,
      date: DateTime.parse(json['date'] as String),
      checkIn: json['checkIn'] == null ? null : DateTime.parse(json['checkIn'] as String).toLocal(),
      checkOut: json['checkOut'] == null ? null : DateTime.parse(json['checkOut'] as String).toLocal(),
      status: AttendanceStatus.fromValue(json['status'] as int),
      notes: json['notes'] as String?,
    );
  }

  final int id;
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final AttendanceStatus status;
  final String? notes;
}

class AttendanceSettings {
  AttendanceSettings({required this.officeLatitude, required this.officeLongitude, required this.radiusMeters});

  factory AttendanceSettings.fromJson(Map<String, dynamic> json) {
    return AttendanceSettings(
      officeLatitude: (json['officeLatitude'] as num?)?.toDouble(),
      officeLongitude: (json['officeLongitude'] as num?)?.toDouble(),
      radiusMeters: json['radiusMeters'] as int? ?? 100,
    );
  }

  final double? officeLatitude;
  final double? officeLongitude;
  final int radiusMeters;

  bool get isOfficeLocationConfigured => officeLatitude != null && officeLongitude != null;
}
