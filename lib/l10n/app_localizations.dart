import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
    Locale('ja'),
  ];

  /// Label for the username field on the login form
  ///
  /// In id, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// Label for the password field on the login form
  ///
  /// In id, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Validation error when username is empty
  ///
  /// In id, this message translates to:
  /// **'Username wajib diisi'**
  String get usernameRequired;

  /// Validation error when password is empty
  ///
  /// In id, this message translates to:
  /// **'Password wajib diisi'**
  String get passwordRequired;

  /// Submit button on the login form
  ///
  /// In id, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// Subtitle shown on the biometric unlock gate
  ///
  /// In id, this message translates to:
  /// **'Sesi Anda masih tersimpan. Verifikasi untuk melanjutkan.'**
  String get unlockSubtitle;

  /// Shown when biometric authentication fails or is cancelled
  ///
  /// In id, this message translates to:
  /// **'Verifikasi biometrik gagal atau dibatalkan.'**
  String get biometricFailed;

  /// Button that triggers biometric authentication
  ///
  /// In id, this message translates to:
  /// **'Buka dengan Sidik Jari / Face ID'**
  String get unlockWithBiometricButton;

  /// Link that switches from the biometric gate to the password form
  ///
  /// In id, this message translates to:
  /// **'Login dengan Password'**
  String get loginWithPasswordButton;

  /// Link that switches back from the password form to the biometric gate
  ///
  /// In id, this message translates to:
  /// **'Kembali ke verifikasi biometrik'**
  String get backToBiometricButton;

  /// Tooltip for the history icon button on the home screen app bar
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get historyTooltip;

  /// Tooltip for the logout icon button on the home screen app bar
  ///
  /// In id, this message translates to:
  /// **'Logout'**
  String get logoutTooltip;

  /// Label/button for the check-in action
  ///
  /// In id, this message translates to:
  /// **'Check In'**
  String get checkIn;

  /// Label/button for the check-out action
  ///
  /// In id, this message translates to:
  /// **'Check Out'**
  String get checkOut;

  /// Button label when checking out again to revise the recorded time
  ///
  /// In id, this message translates to:
  /// **'Perbarui Check Out'**
  String get updateCheckOutButton;

  /// Line showing today's attendance status
  ///
  /// In id, this message translates to:
  /// **'Status: {status}'**
  String statusLine(String status);

  /// Warning shown when the office location has not been configured
  ///
  /// In id, this message translates to:
  /// **'Lokasi kantor belum diatur oleh admin. Hubungi HR.'**
  String get officeLocationNotConfigured;

  /// Button that opens the mark-status screen (absent/half day)
  ///
  /// In id, this message translates to:
  /// **'Ajukan Absen / Setengah Hari'**
  String get requestAbsentButton;

  /// Button that opens the leave-request screen (leave/sick)
  ///
  /// In id, this message translates to:
  /// **'Ajukan Cuti / Sakit'**
  String get requestLeaveButton;

  /// App bar title for the mark-status screen
  ///
  /// In id, this message translates to:
  /// **'Ajukan Absen / Setengah Hari'**
  String get markStatusTitle;

  /// Label for the date picker field
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get dateLabel;

  /// Label for the attendance-status dropdown
  ///
  /// In id, this message translates to:
  /// **'Jenis'**
  String get typeLabel;

  /// Label for the optional notes field
  ///
  /// In id, this message translates to:
  /// **'Catatan (opsional)'**
  String get notesLabel;

  /// Submit button on the mark-status form
  ///
  /// In id, this message translates to:
  /// **'Kirim'**
  String get submitButton;

  /// App bar title for the history screen
  ///
  /// In id, this message translates to:
  /// **'Riwayat Absensi'**
  String get historyTitle;

  /// Shown when there is no attendance history yet
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat.'**
  String get noHistory;

  /// Check-in/check-out time summary line in the history list
  ///
  /// In id, this message translates to:
  /// **'In: {checkIn}   Out: {checkOut}'**
  String attendanceSummary(String checkIn, String checkOut);

  /// Attendance status: present
  ///
  /// In id, this message translates to:
  /// **'Hadir'**
  String get statusPresent;

  /// Attendance status: absent
  ///
  /// In id, this message translates to:
  /// **'Absen'**
  String get statusAbsent;

  /// Attendance status: late
  ///
  /// In id, this message translates to:
  /// **'Terlambat'**
  String get statusLate;

  /// Attendance status: half day
  ///
  /// In id, this message translates to:
  /// **'Setengah Hari'**
  String get statusHalfDay;

  /// Attendance status: sick leave
  ///
  /// In id, this message translates to:
  /// **'Sakit'**
  String get statusSick;

  /// Attendance status: annual/paid leave
  ///
  /// In id, this message translates to:
  /// **'Cuti'**
  String get statusLeave;

  /// Shown when the device's location service is turned off
  ///
  /// In id, this message translates to:
  /// **'Aktifkan layanan lokasi (GPS) terlebih dahulu.'**
  String get locationServiceDisabled;

  /// Shown when the app is denied location permission
  ///
  /// In id, this message translates to:
  /// **'Izin lokasi ditolak. Aktifkan izin lokasi di pengaturan aplikasi.'**
  String get locationPermissionDenied;

  /// Shown when a request fails due to no/unstable network connection
  ///
  /// In id, this message translates to:
  /// **'Gagal terhubung ke server. Periksa koneksi internet/jaringan Anda.'**
  String get connectionErrorMessage;

  /// Fallback shown when a request fails without a specific server message
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan. Coba lagi.'**
  String get genericErrorMessage;

  /// Fallback shown when login fails without a specific server message
  ///
  /// In id, this message translates to:
  /// **'Login gagal. Periksa username/password Anda.'**
  String get loginGenericError;

  /// Tooltip for the language-picker icon button
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get languageTooltip;

  /// Title of the language-picker dialog
  ///
  /// In id, this message translates to:
  /// **'Pilih Bahasa'**
  String get chooseLanguageTitle;

  /// Option to follow the device's system language instead of a fixed one
  ///
  /// In id, this message translates to:
  /// **'Ikuti Bahasa Sistem'**
  String get systemDefaultLanguage;

  /// App bar title for the leave-request screen
  ///
  /// In id, this message translates to:
  /// **'Ajukan Cuti / Sakit'**
  String get leaveRequestTitle;

  /// Label for the leave-type dropdown on the leave-request form
  ///
  /// In id, this message translates to:
  /// **'Jenis Cuti'**
  String get leaveTypeLabel;

  /// Validation error when no leave type is selected
  ///
  /// In id, this message translates to:
  /// **'Jenis cuti wajib dipilih'**
  String get leaveTypeRequired;

  /// Label for the start/end date range field on the leave-request form
  ///
  /// In id, this message translates to:
  /// **'Periode Cuti'**
  String get dateRangeLabel;

  /// Placeholder shown before a date range has been picked
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggal mulai & selesai'**
  String get selectDateRangePlaceholder;

  /// Label for the optional reason field on the leave-request form
  ///
  /// In id, this message translates to:
  /// **'Alasan (opsional)'**
  String get reasonLabel;

  /// Tooltip for the icon button that opens the leave-request history screen
  ///
  /// In id, this message translates to:
  /// **'Riwayat Cuti'**
  String get leaveHistoryTooltip;

  /// App bar title for the leave-request history screen
  ///
  /// In id, this message translates to:
  /// **'Riwayat Pengajuan Cuti'**
  String get leaveHistoryTitle;

  /// Shown when there are no leave requests yet
  ///
  /// In id, this message translates to:
  /// **'Belum ada pengajuan cuti.'**
  String get noLeaveHistory;

  /// Leave request status: pending approval
  ///
  /// In id, this message translates to:
  /// **'Menunggu'**
  String get leaveStatusPending;

  /// Leave request status: approved
  ///
  /// In id, this message translates to:
  /// **'Disetujui'**
  String get leaveStatusApproved;

  /// Leave request status: rejected
  ///
  /// In id, this message translates to:
  /// **'Ditolak'**
  String get leaveStatusRejected;

  /// Period and duration summary line in the leave-request history list
  ///
  /// In id, this message translates to:
  /// **'{startDate} - {endDate} ({totalDays} hari)'**
  String leavePeriodSummary(String startDate, String endDate, String totalDays);

  /// Reason line shown under each entry in the leave-request history list
  ///
  /// In id, this message translates to:
  /// **'Alasan: {reason}'**
  String leaveReasonSummary(String reason);

  /// Placeholder shown before a file has been attached
  ///
  /// In id, this message translates to:
  /// **'Ketuk untuk lampirkan file'**
  String get attachmentPlaceholder;

  /// Validation error when the picked attachment exceeds the size limit
  ///
  /// In id, this message translates to:
  /// **'Ukuran file maksimal 5 MB.'**
  String get attachmentTooLarge;

  /// Validation error shown when a specific attachment slot is required but was left empty
  ///
  /// In id, this message translates to:
  /// **'{name} wajib diisi.'**
  String attachmentSlotRequiredMessage(String name);

  /// Short tag next to an attachment slot's name when it is required
  ///
  /// In id, this message translates to:
  /// **'Wajib'**
  String get attachmentRequiredTag;

  /// Short tag next to an attachment slot's name when it is optional
  ///
  /// In id, this message translates to:
  /// **'Opsional'**
  String get attachmentOptionalTag;

  /// Tooltip for the button that removes a picked (not-yet-uploaded) attachment
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get attachmentRemoveTooltip;

  /// Title of the dialog shown when the leave request was submitted but some attachments failed
  ///
  /// In id, this message translates to:
  /// **'Peringatan Lampiran'**
  String get attachmentWarningsTitle;

  /// Generic OK/close button
  ///
  /// In id, this message translates to:
  /// **'OK'**
  String get okButton;

  /// Title of the attachments bottom sheet on the leave-history screen
  ///
  /// In id, this message translates to:
  /// **'Lampiran'**
  String get attachmentsTitle;

  /// Shown when a leave request has no attachments
  ///
  /// In id, this message translates to:
  /// **'Tidak ada lampiran.'**
  String get noAttachments;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
