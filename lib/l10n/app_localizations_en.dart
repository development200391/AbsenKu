// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get usernameLabel => 'Username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get loginButton => 'Login';

  @override
  String get unlockSubtitle =>
      'Your session is still saved. Verify to continue.';

  @override
  String get biometricFailed =>
      'Biometric verification failed or was cancelled.';

  @override
  String get unlockWithBiometricButton => 'Unlock with Fingerprint / Face ID';

  @override
  String get loginWithPasswordButton => 'Login with Password';

  @override
  String get backToBiometricButton => 'Back to biometric verification';

  @override
  String get historyTooltip => 'History';

  @override
  String get logoutTooltip => 'Logout';

  @override
  String get checkIn => 'Check In';

  @override
  String get checkOut => 'Check Out';

  @override
  String get updateCheckOutButton => 'Update Check Out';

  @override
  String statusLine(String status) {
    return 'Status: $status';
  }

  @override
  String get officeLocationNotConfigured =>
      'Office location has not been set up by admin. Contact HR.';

  @override
  String get requestAbsentButton => 'Request Absence / Half Day';

  @override
  String get requestLeaveButton => 'Request Leave / Sick Leave';

  @override
  String get markStatusTitle => 'Request Absence / Half Day';

  @override
  String get dateLabel => 'Date';

  @override
  String get typeLabel => 'Type';

  @override
  String get notesLabel => 'Notes (optional)';

  @override
  String get submitButton => 'Submit';

  @override
  String get historyTitle => 'Attendance History';

  @override
  String get noHistory => 'No history yet.';

  @override
  String attendanceSummary(String checkIn, String checkOut) {
    return 'In: $checkIn   Out: $checkOut';
  }

  @override
  String get statusPresent => 'Present';

  @override
  String get statusAbsent => 'Absent';

  @override
  String get statusLate => 'Late';

  @override
  String get statusHalfDay => 'Half Day';

  @override
  String get statusSick => 'Sick';

  @override
  String get statusLeave => 'Leave';

  @override
  String get locationServiceDisabled =>
      'Please enable location services (GPS) first.';

  @override
  String get locationPermissionDenied =>
      'Location permission denied. Enable it in the app settings.';

  @override
  String get connectionErrorMessage =>
      'Failed to connect to the server. Check your internet/network connection.';

  @override
  String get genericErrorMessage => 'Something went wrong. Please try again.';

  @override
  String get loginGenericError => 'Login failed. Check your username/password.';

  @override
  String get languageTooltip => 'Language';

  @override
  String get chooseLanguageTitle => 'Choose Language';

  @override
  String get systemDefaultLanguage => 'Follow System Language';

  @override
  String get leaveRequestTitle => 'Request Leave / Sick Leave';

  @override
  String get leaveTypeLabel => 'Leave Type';

  @override
  String get leaveTypeRequired => 'Leave type is required';

  @override
  String get dateRangeLabel => 'Leave Period';

  @override
  String get selectDateRangePlaceholder => 'Select start & end date';

  @override
  String get reasonLabel => 'Reason (optional)';

  @override
  String get leaveHistoryTooltip => 'Leave History';

  @override
  String get leaveHistoryTitle => 'Leave Request History';

  @override
  String get noLeaveHistory => 'No leave requests yet.';

  @override
  String get leaveStatusPending => 'Pending';

  @override
  String get leaveStatusApproved => 'Approved';

  @override
  String get leaveStatusRejected => 'Rejected';

  @override
  String leavePeriodSummary(
    String startDate,
    String endDate,
    String totalDays,
  ) {
    return '$startDate - $endDate ($totalDays day(s))';
  }

  @override
  String get attachmentLabel => 'Attachment (optional)';

  @override
  String get attachmentLabelRequired => 'Attachment (required)';

  @override
  String get attachmentPlaceholder => 'Tap to attach a file';

  @override
  String get attachmentTooLarge => 'File must be 5 MB or smaller.';

  @override
  String get attachmentRequiredMessage => 'Please attach at least one file.';

  @override
  String attachmentMaxCountMessage(int count) {
    return 'You can attach up to $count file(s).';
  }

  @override
  String get attachmentAddButton => 'Add File';

  @override
  String get attachmentRemoveTooltip => 'Remove';

  @override
  String get attachmentWarningsTitle => 'Attachment Warning';

  @override
  String get okButton => 'OK';

  @override
  String get attachmentsTitle => 'Attachments';

  @override
  String get noAttachments => 'No attachments.';
}
