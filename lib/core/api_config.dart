class ApiConfig {
  /// Base URL of ERP.API.
  ///
  /// - Android emulator: use `http://10.0.2.2:60043/api/v1` (reaches host's localhost).
  /// - Physical device over USB: keep `127.0.0.1` and run
  ///   `adb reverse tcp:60043 tcp:60043` so the phone's localhost:60043 tunnels
  ///   to the host machine.
  static const String baseUrl = 'http://192.168.137.1:60043/api/v1';
}
