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

  Future<void> restore() async {
    final token = await _storage.getAccessToken();
    isAuthenticated = token != null;
    isInitializing = false;
    notifyListeners();
  }

  void markAuthenticated() {
    isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.clear();
    isAuthenticated = false;
    notifyListeners();
  }
}
