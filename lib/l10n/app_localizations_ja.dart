// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get usernameLabel => 'ユーザー名';

  @override
  String get passwordLabel => 'パスワード';

  @override
  String get usernameRequired => 'ユーザー名を入力してください';

  @override
  String get passwordRequired => 'パスワードを入力してください';

  @override
  String get loginButton => 'ログイン';

  @override
  String get unlockSubtitle => 'セッションはまだ保存されています。続行するには認証してください。';

  @override
  String get biometricFailed => '生体認証に失敗またはキャンセルされました。';

  @override
  String get unlockWithBiometricButton => '指紋 / Face IDで解除';

  @override
  String get loginWithPasswordButton => 'パスワードでログイン';

  @override
  String get backToBiometricButton => '生体認証に戻る';

  @override
  String get historyTooltip => '履歴';

  @override
  String get logoutTooltip => 'ログアウト';

  @override
  String get checkIn => '出勤';

  @override
  String get checkOut => '退勤';

  @override
  String get updateCheckOutButton => '退勤時刻を更新';

  @override
  String statusLine(String status) {
    return 'ステータス: $status';
  }

  @override
  String get officeLocationNotConfigured =>
      'オフィスの位置情報が管理者によって設定されていません。人事部にお問い合わせください。';

  @override
  String get requestAbsentButton => '欠勤 / 半休を申請';

  @override
  String get requestLeaveButton => '休暇 / 病欠を申請';

  @override
  String get markStatusTitle => '欠勤 / 半休申請';

  @override
  String get dateLabel => '日付';

  @override
  String get typeLabel => '種類';

  @override
  String get notesLabel => 'メモ（任意）';

  @override
  String get submitButton => '送信';

  @override
  String get historyTitle => '勤怠履歴';

  @override
  String get noHistory => '履歴がまだありません。';

  @override
  String attendanceSummary(String checkIn, String checkOut) {
    return '出勤: $checkIn   退勤: $checkOut';
  }

  @override
  String get statusPresent => '出勤';

  @override
  String get statusAbsent => '欠勤';

  @override
  String get statusLate => '遅刻';

  @override
  String get statusHalfDay => '半休';

  @override
  String get statusSick => '病欠';

  @override
  String get statusLeave => '休暇';

  @override
  String get locationServiceDisabled => 'まず位置情報サービス（GPS）を有効にしてください。';

  @override
  String get locationPermissionDenied =>
      '位置情報の権限が拒否されました。アプリの設定で位置情報を有効にしてください。';

  @override
  String get connectionErrorMessage =>
      'サーバーに接続できませんでした。インターネット/ネットワーク接続を確認してください。';

  @override
  String get genericErrorMessage => 'エラーが発生しました。もう一度お試しください。';

  @override
  String get loginGenericError => 'ログインに失敗しました。ユーザー名とパスワードを確認してください。';

  @override
  String get languageTooltip => '言語';

  @override
  String get chooseLanguageTitle => '言語を選択';

  @override
  String get systemDefaultLanguage => 'システム言語に従う';

  @override
  String get leaveRequestTitle => '休暇 / 病欠申請';

  @override
  String get leaveTypeLabel => '休暇の種類';

  @override
  String get leaveTypeRequired => '休暇の種類を選択してください';

  @override
  String get dateRangeLabel => '休暇期間';

  @override
  String get selectDateRangePlaceholder => '開始日と終了日を選択';

  @override
  String get reasonLabel => '理由（任意）';

  @override
  String get leaveHistoryTooltip => '休暇履歴';

  @override
  String get leaveHistoryTitle => '休暇申請履歴';

  @override
  String get noLeaveHistory => '休暇申請はまだありません。';

  @override
  String get leaveStatusPending => '承認待ち';

  @override
  String get leaveStatusApproved => '承認済み';

  @override
  String get leaveStatusRejected => '却下';

  @override
  String leavePeriodSummary(
    String startDate,
    String endDate,
    String totalDays,
  ) {
    return '$startDate 〜 $endDate（$totalDays日）';
  }
}
