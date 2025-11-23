import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricEmailKey = 'biometric_email';
  static const String _biometricPasswordKey = 'biometric_password';

  /// Verifica se o dispositivo suporta biometria
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException {
      return false;
    }
  }

  /// ObtÃ©m a lista de tipos de biometria disponÃ­veis
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return <BiometricType>[];
    }
  }

  /// Autentica o usuÃ¡rio usando biometria
  Future<bool> authenticate({
    String reason = 'Por favor, autentique-se para acessar o aplicativo',
  }) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return didAuthenticate;
    } on PlatformException {
      return false;
    }
  }

  /// Verifica se a biometria estÃ¡ habilitada para o aplicativo
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Habilita a biometria para o aplicativo
  Future<void> enableBiometric(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, true);
    await prefs.setString(_biometricEmailKey, email);
    await prefs.setString(_biometricPasswordKey, password);
  }

  /// Desabilita a biometria para o aplicativo
  Future<void> disableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_biometricEnabledKey);
    await prefs.remove(_biometricEmailKey);
    await prefs.remove(_biometricPasswordKey);
  }

  /// ObtÃ©m as credenciais salvas para login biomÃ©trico
  Future<Map<String, String>?> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_biometricEmailKey);
    final password = prefs.getString(_biometricPasswordKey);

    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }

    return null;
  }

  /// ObtÃ©m o texto descritivo dos tipos de biometria disponÃ­veis
  String getBiometricTypesText(List<BiometricType> types) {
    if (types.isEmpty) return 'Nenhuma';

    List<String> typeNames = [];
    for (var type in types) {
      switch (type) {
        case BiometricType.face:
          typeNames.add('Reconhecimento facial');
          break;
        case BiometricType.fingerprint:
          typeNames.add('Digital');
          break;
        case BiometricType.iris:
          typeNames.add('Ãris');
          break;
        case BiometricType.strong:
          typeNames.add('Biometria forte');
          break;
        case BiometricType.weak:
          typeNames.add('Biometria fraca');
          break;
      }
    }

    return typeNames.join(', ');
  }
}
