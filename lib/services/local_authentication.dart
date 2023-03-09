import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthenticationService {
  final _auth = LocalAuthentication();
  bool _isProtectionEnabled = false;

  bool get isProtectionEnabled => _isProtectionEnabled;
  set isProtectionEnabled(bool enabled) => _isProtectionEnabled = enabled;

  bool isAuthenticated = false;

  Future<bool> authenticate() async {
    try {
      isAuthenticated = await _auth.authenticateWithBiometrics(
        localizedReason: 'authenticate to access',
        useErrorDialogs: true,
        stickyAuth: true,
      );
      return isAuthenticated;
    } on PlatformException catch (e) {
      //e);
    }
    return false;
  }
}
