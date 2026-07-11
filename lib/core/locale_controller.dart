import 'package:flutter/widgets.dart';

import 'secure_storage.dart';

/// Holds the user's chosen app language. `null` means "follow the device's
/// system language" (Flutter's default behavior).
class LocaleController extends ChangeNotifier {
  LocaleController(this._storage);

  final SecureStorageService _storage;

  Locale? _locale;
  Locale? get locale => _locale;

  Future<void> restore() async {
    final code = await _storage.getLocaleCode();
    if (code != null) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    await _storage.saveLocaleCode(locale?.languageCode);
    notifyListeners();
  }
}
