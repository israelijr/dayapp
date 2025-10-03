import 'package:flutter/material.dart';
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
    } on PlatformException catch (e) {
      debugPrint('Erro ao verificar biometria: $e');
      return false;
    }
  }

  /// Obtém a lista de tipos de biometria disponíveis
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint('Erro ao obter biometrias disponíveis: $e');
      return <BiometricType>[];
    }
  }

  /// Autentica o usuário usando biometria
  Future<bool> authenticate({
    String reason = 'Por favor, autentique-se para acessar o aplicativo',
  }) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('Erro ao autenticar: $e');
      return false;
    }
  }

  /// Verifica se a biometria está habilitada para o aplicativo
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

  /// Obtém as credenciais salvas para login biométrico
  Future<Map<String, String>?> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_biometricEmailKey);
    final password = prefs.getString(_biometricPasswordKey);

    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }

    return null;
  }

  /// Obtém o texto descritivo dos tipos de biometria disponíveis
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
          typeNames.add('Íris');
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
