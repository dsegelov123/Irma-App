import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Service managing native biometric access gates (FaceID / TouchID / BiometricPrompt).
class BiometricService {
  static final _auth = LocalAuthentication();

  /// Determines if the hardware supports biometric checks and has enrolled templates.
  static Future<bool> canAuthenticate() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return isSupported && canCheck;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Triggers the native platform biometric authentication dialog.
  static Future<bool> authenticate() async {
    try {
      if (!await canAuthenticate()) {
        return false;
      }
      return await _auth.authenticate(
        localizedReason: 'Access Irma securely with your biometric login',
      );
    } on PlatformException catch (_) {
      return false;
    }
  }
}
