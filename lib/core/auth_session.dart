import 'package:flutter/foundation.dart';

import 'secure_storage.dart';

/// Tracks whether the app currently has a usable session. The API client
/// calls [logout] when a token refresh fails so the router can redirect back
/// to the login screen.
class AuthSession extends ChangeNotifier {
  AuthSession(this._storage);

  final SecureStorageService _storage;

  bool isAuthenticated = false;
  bool isInitializing = true;

  /// Whether a token from a previous login is still on disk. When true but
  /// [isAuthenticated] is false, the login screen shows a biometric-unlock
  /// gate instead of the username/password form.
  bool hasStoredSession = false;

  Future<void> restore() async {
    final token = await _storage.getAccessToken();
    hasStoredSession = token != null;
    isAuthenticated = false;
    isInitializing = false;
    notifyListeners();
  }

  void markAuthenticated() {
    isAuthenticated = true;
    hasStoredSession = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.clear();
    isAuthenticated = false;
    hasStoredSession = false;
    notifyListeners();
  }
}
