import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'secure_storage_service.dart';

/// Serviço para recuperação de PIN por e-mail
/// Gera códigos de recuperação e envia por e-mail
class PinRecoveryService {
  static final PinRecoveryService _instance = PinRecoveryService._internal();
  factory PinRecoveryService() => _instance;
  PinRecoveryService._internal();

  final SecureStorageService _secureStorage = SecureStorageService();

  static const String _recoveryCodeKey = 'pin_recovery_code';
  static const String _recoveryCodeTimeKey = 'pin_recovery_code_time';
  static const String _legacyUserEmailKey = 'user_email';

  /// Duração de validade do código de recuperação (em minutos)
  static const int recoveryCodeValidityMinutes = 15;

  /// Gera um código de recuperação de 6 dígitos
  String _generateRecoveryCode() {
    final random = Random.secure();
    final code = random.nextInt(900000) + 100000; // Gera de 100000 a 999999
    return code.toString();
  }

  /// Salva o e-mail do usuário (armazenamento seguro)
  Future<void> saveUserEmail(String email) async {
    await _secureStorage.saveRecoveryEmail(email);

    // Remove dados legados se existirem
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_legacyUserEmailKey);
  }

  /// Obtém o e-mail do usuário salvo
  /// Inclui migração de dados legados
  Future<String?> getUserEmail() async {
    // Primeiro tenta do armazenamento seguro
    final secureEmail = await _secureStorage.getRecoveryEmail();
    if (secureEmail != null) return secureEmail;

    // Verifica se há dados legados para migrar
    final prefs = await SharedPreferences.getInstance();
    final legacyEmail = prefs.getString(_legacyUserEmailKey);

    if (legacyEmail != null) {
      // Migra para armazenamento seguro
      await _secureStorage.saveRecoveryEmail(legacyEmail);
      await prefs.remove(_legacyUserEmailKey);
      return legacyEmail;
    }

    return null;
  }

  /// Gera e envia um código de recuperação por e-mail
  Future<bool> sendRecoveryCode(String email) async {
    try {
      // Gera o código
      final code = _generateRecoveryCode();
      final now = DateTime.now();

      // Salva o código e o timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_recoveryCodeKey, code);
      await prefs.setString(_recoveryCodeTimeKey, now.toIso8601String());

      // Compõe o e-mail
      final subject = Uri.encodeComponent(
        'DayApp - Código de Recuperação de PIN',
      );
      final body = Uri.encodeComponent(
        'Olá,\n\n'
        'Você solicitou a recuperação do seu PIN no DayApp.\n\n'
        'Seu código de recuperação é: $code\n\n'
        'Este código expira em $recoveryCodeValidityMinutes minutos.\n\n'
        'Se você não solicitou este código, ignore este e-mail.\n\n'
        'Atenciosamente,\n'
        'Equipe DayApp',
      );

      // Tenta abrir o cliente de e-mail
      final emailUri = Uri.parse('mailto:$email?subject=$subject&body=$body');

      try {
        final launched = await launchUrl(
          emailUri,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          return true;
        }
      } catch (e) {
        // Não conseguiu abrir app de e-mail - usar fallback
      }

      // Fallback: retorna true para mostrar o código de forma segura

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verifica se há um código de recuperação ativo
  Future<bool> hasActiveRecoveryCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_recoveryCodeKey);
      final timeString = prefs.getString(_recoveryCodeTimeKey);

      if (savedCode == null || timeString == null) {
        return false;
      }

      // Verifica se o código ainda é válido (não expirou)
      final codeTime = DateTime.parse(timeString);
      final now = DateTime.now();
      final difference = now.difference(codeTime);

      return difference.inMinutes <= recoveryCodeValidityMinutes;
    } catch (e) {
      return false;
    }
  }

  /// Obtém o código de recuperação ativo (para exibição segura quando não há app de e-mail)
  Future<String?> getActiveRecoveryCode() async {
    if (await hasActiveRecoveryCode()) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_recoveryCodeKey);
    }
    return null;
  }

  /// Verifica se o código de recuperação é válido
  Future<bool> verifyRecoveryCode(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_recoveryCodeKey);
      final timeString = prefs.getString(_recoveryCodeTimeKey);

      if (savedCode == null || timeString == null) {
        return false;
      }

      // Verifica se o código está correto
      if (savedCode != code) {
        return false;
      }

      // Verifica se o código ainda é válido (não expirou)
      final codeTime = DateTime.parse(timeString);
      final now = DateTime.now();
      final difference = now.difference(codeTime);

      if (difference.inMinutes > recoveryCodeValidityMinutes) {
        // Código expirado, limpa os dados
        await clearRecoveryCode();
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Limpa o código de recuperação salvo
  Future<void> clearRecoveryCode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recoveryCodeKey);
    await prefs.remove(_recoveryCodeTimeKey);
  }

  /// Obtém o tempo restante de validade do código (em minutos)
  Future<int?> getRemainingTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(_recoveryCodeTimeKey);

      if (timeString == null) return null;

      final codeTime = DateTime.parse(timeString);
      final now = DateTime.now();
      final difference = now.difference(codeTime);
      final remaining = recoveryCodeValidityMinutes - difference.inMinutes;

      return remaining > 0 ? remaining : 0;
    } catch (e) {
      return null;
    }
  }
}
