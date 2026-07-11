// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get usernameLabel => 'Username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get usernameRequired => 'Username wajib diisi';

  @override
  String get passwordRequired => 'Password wajib diisi';

  @override
  String get loginButton => 'Login';

  @override
  String get unlockSubtitle =>
      'Sesi Anda masih tersimpan. Verifikasi untuk melanjutkan.';

  @override
  String get biometricFailed => 'Verifikasi biometrik gagal atau dibatalkan.';

  @override
  String get unlockWithBiometricButton => 'Buka dengan Sidik Jari / Face ID';

  @override
  String get loginWithPasswordButton => 'Login dengan Password';

  @override
  String get backToBiometricButton => 'Kembali ke verifikasi biometrik';

  @override
  String get historyTooltip => 'Riwayat';

  @override
  String get logoutTooltip => 'Logout';

  @override
  String get checkIn => 'Check In';

  @override
  String get checkOut => 'Check Out';

  @override
  String get updateCheckOutButton => 'Perbarui Check Out';

  @override
  String statusLine(String status) {
    return 'Status: $status';
  }

  @override
  String get officeLocationNotConfigured =>
      'Lokasi kantor belum diatur oleh admin. Hubungi HR.';

  @override
  String get requestLeaveButton => 'Ajukan Izin / Sakit / Cuti / Setengah Hari';

  @override
  String get markStatusTitle => 'Ajukan Izin';

  @override
  String get dateLabel => 'Tanggal';

  @override
  String get typeLabel => 'Jenis';

  @override
  String get notesLabel => 'Catatan (opsional)';

  @override
  String get submitButton => 'Kirim';

  @override
  String get historyTitle => 'Riwayat Absensi';

  @override
  String get noHistory => 'Belum ada riwayat.';

  @override
  String attendanceSummary(String checkIn, String checkOut) {
    return 'In: $checkIn   Out: $checkOut';
  }

  @override
  String get statusPresent => 'Hadir';

  @override
  String get statusAbsent => 'Absen';

  @override
  String get statusLate => 'Terlambat';

  @override
  String get statusHalfDay => 'Setengah Hari';

  @override
  String get statusSick => 'Sakit';

  @override
  String get statusLeave => 'Cuti';

  @override
  String get locationServiceDisabled =>
      'Aktifkan layanan lokasi (GPS) terlebih dahulu.';

  @override
  String get locationPermissionDenied =>
      'Izin lokasi ditolak. Aktifkan izin lokasi di pengaturan aplikasi.';

  @override
  String get connectionErrorMessage =>
      'Gagal terhubung ke server. Periksa koneksi internet/jaringan Anda.';

  @override
  String get genericErrorMessage => 'Terjadi kesalahan. Coba lagi.';

  @override
  String get loginGenericError =>
      'Login gagal. Periksa username/password Anda.';
}
