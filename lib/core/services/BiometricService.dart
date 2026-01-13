import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  static final _auth = LocalAuthentication();

  // 1. Check wach Telephon fih Basma aslan
  static Future<bool> isBiometricAvailable() async {
    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      print("Biometric Check Error: $e");
      return false;
    }
  }

  // 2. Tleb l-Basma (Show Dialog)
  static Future<bool> authenticate() async {
    try {
      // Check availablity first
      if (!await isBiometricAvailable()) return false;

      return await _auth.authenticate(
        localizedReason: 'Scan your fingerprint to unlock',
        options: const AuthenticationOptions(
          stickyAuth: true, // Bach tbqa dialog hta ila jat notification
          biometricOnly: true, // La, bghina gher Basma (PIN dyalna hsen)
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      print("Auth Error: $e");
      return false; // Ila user dar Cancel aw error
    }
  }
}