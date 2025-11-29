import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'secure_storage_service.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final SecureStorageService _secureStorage = SecureStorageService();

  // Chaves legadas para migração (SharedPreferences inseguro)
  static const String _legacyBiometricEnabledKey = 'biometric_enabled';
  static const String _legacyBiometricEmailKey = 'biometric_email';
  static const String _legacyBiometricPasswordKey = 'biometric_password';

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

  /// Verifica se a biometria está habilitada para o aplicativo
  /// Inclui migração automática de dados legados
  Future<bool> isBiometricEnabled() async {
    // Primeiro verifica no armazenamento seguro
    final secureEnabled = await _secureStorage.isBiometricEnabled();
    if (secureEnabled) return true;

    // Verifica se há dados legados para migrar
    final prefs = await SharedPreferences.getInstance();
    final legacyEnabled = prefs.getBool(_legacyBiometricEnabledKey) ?? false;

    if (legacyEnabled) {
      // Migra dados legados para armazenamento seguro
      await _migrateLegacyData();
      return true;
    }

    return false;
  }

  /// Habilita a biometria para o aplicativo (armazenamento seguro)
  Future<void> enableBiometric(String email, String password) async {
    await _secureStorage.saveBiometricCredentials(email, password);

    // Remove dados legados se existirem
    await _removeLegacyData();
  }

  /// Desabilita a biometria para o aplicativo
  Future<void> disableBiometric() async {
    await _secureStorage.removeBiometricCredentials();

    // Remove dados legados se existirem
    await _removeLegacyData();
  }

  /// Obtém as credenciais salvas para login biométrico (armazenamento seguro)
  Future<Map<String, String>?> getSavedCredentials() async {
    // Primeiro tenta do armazenamento seguro
    final secureCredentials = await _secureStorage.getBiometricCredentials();
    if (secureCredentials != null) {
      return secureCredentials;
    }

    // Verifica se há dados legados para migrar
    final prefs = await SharedPreferences.getInstance();
    final legacyEmail = prefs.getString(_legacyBiometricEmailKey);
    final legacyPassword = prefs.getString(_legacyBiometricPasswordKey);

    if (legacyEmail != null && legacyPassword != null) {
      // Migra para armazenamento seguro
      await _secureStorage.saveBiometricCredentials(
        legacyEmail,
        legacyPassword,
      );
      await _removeLegacyData();
      return {'email': legacyEmail, 'password': legacyPassword};
    }

    return null;
  }

  /// Migra dados legados do SharedPreferences para SecureStorage
  Future<void> _migrateLegacyData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_legacyBiometricEmailKey);
    final password = prefs.getString(_legacyBiometricPasswordKey);

    if (email != null && password != null) {
      await _secureStorage.saveBiometricCredentials(email, password);
    }

    await _removeLegacyData();
  }

  /// Remove dados legados do SharedPreferences
  Future<void> _removeLegacyData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_legacyBiometricEnabledKey);
    await prefs.remove(_legacyBiometricEmailKey);
    await prefs.remove(_legacyBiometricPasswordKey);
  }

  /// ObtÃ©m o texto descritivo dos tipos de biometria disponÃ­veis
  String getBiometricTypesText(List<BiometricType> types) {
    if (types.isEmpty) return 'Nenhuma';

    final List<String> typeNames = [];
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
