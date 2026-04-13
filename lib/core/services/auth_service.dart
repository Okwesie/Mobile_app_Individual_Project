import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  Future<bool> hasBiometrics() async {
    try {
      final enrolled = await _auth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  /// Returns true on success. Returns false if auth fails or is not available
  /// (in which case the caller should decide whether to allow fallback).
  Future<bool> authenticate() async {
    try {
      final canCheck = await isAvailable();
      if (!canCheck) return true; // no biometric hardware — allow through

      return await _auth.authenticate(
        localizedReason: 'Authenticate to access your Adventure Logs',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      // passcode not set, no biometrics enrolled — allow through
      if (e.code == 'NotEnrolled' ||
          e.code == 'NotAvailable' ||
          e.code == 'PasscodeNotSet') {
        return true;
      }
      return false;
    }
  }
}
