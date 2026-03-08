import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService(LocalAuthentication());
});

class BiometricService {
  final LocalAuthentication _auth;
  bool _isAuthenticating = false;
  DateTime? _uiUnavailableRetryAfter;
  LocalAuthExceptionCode? _lastExceptionCode;

  BiometricService(this._auth);

  LocalAuthExceptionCode? get lastExceptionCode => _lastExceptionCode;

  Future<bool> canCheck() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;

      final canCheck = await _auth.canCheckBiometrics;
      final available = await _auth.getAvailableBiometrics();

      // Some Android devices report an empty list even when biometrics are
      // supported/enrolled; treat canCheckBiometrics as sufficient.
      return canCheck || available.isNotEmpty;
    } on PlatformException catch (e) {
      debugPrint("BIO: canCheck() platform exception: ${e.code} ${e.message}");
      _lastExceptionCode = null;
      return false;
    } catch (e) {
      debugPrint("BIO: canCheck() unknown error: $e");
      _lastExceptionCode = null;
      return false;
    }
  }

  Future<bool> authenticate() async {
    final now = DateTime.now();
    if (_uiUnavailableRetryAfter != null &&
        now.isBefore(_uiUnavailableRetryAfter!)) {
      debugPrint("BIO: authenticate() blocked due to recent uiUnavailable");
      _lastExceptionCode = LocalAuthExceptionCode.uiUnavailable;
      return false;
    }

    if (_isAuthenticating) {
      debugPrint("BIO: authenticate() ignored, already in progress");
      return false;
    }

    debugPrint("BIO: authenticate() called");
    _isAuthenticating = true;
    try {
      final ok = await _auth.authenticate(
        localizedReason: "Authenticate to continue",
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      _lastExceptionCode = null;
      debugPrint("BIO: authenticate() result=$ok");
      return ok;
    } on LocalAuthException catch (e) {
      _lastExceptionCode = e.code;
      if (e.code == LocalAuthExceptionCode.uiUnavailable) {
        _uiUnavailableRetryAfter = DateTime.now().add(
          const Duration(seconds: 3),
        );
      }
      debugPrint("BIO: LocalAuthException code=${e.code}");
      return false;
    } catch (e) {
      _lastExceptionCode = null;
      debugPrint("BIO: unknown error: $e");
      return false;
    } finally {
      _isAuthenticating = false;
    }
  }
}
