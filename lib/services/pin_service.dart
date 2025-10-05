import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class PinService {
  static const String _pinKey = 'user_pin';
  static const String _pinEnabledKey = 'pin_enabled';

  /// Verifica se o PIN está habilitado
  Future<bool> isPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pinEnabledKey) ?? false;
  }

  /// Habilita/desabilita o PIN
  Future<void> setPinEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pinEnabledKey, enabled);
  }

  /// Salva um novo PIN (com hash)
  Future<void> savePin(String pin) async {
    if (pin.length < 4 || pin.length > 8) {
      throw ArgumentError('PIN deve ter entre 4 e 8 dígitos');
    }

    // Verifica se contém apenas números
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      throw ArgumentError('PIN deve conter apenas números');
    }

    final prefs = await SharedPreferences.getInstance();
    final hashedPin = _hashPin(pin);
    await prefs.setString(_pinKey, hashedPin);
    await setPinEnabled(true);
  }

  /// Verifica se o PIN está correto
  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString(_pinKey);

    if (savedPin == null) return false;

    final hashedPin = _hashPin(pin);
    return hashedPin == savedPin;
  }

  /// Remove o PIN e desabilita a funcionalidade
  Future<void> removePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
    await setPinEnabled(false);
  }

  /// Verifica se existe um PIN salvo
  Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinKey) != null;
  }

  /// Gera hash do PIN para segurança
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
