import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      return supported && canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate({String reason = 'Verifikasi identitas Anda untuk masuk ke AbsenKu'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
    } catch (_) {
      return false;
    }
  }
}
