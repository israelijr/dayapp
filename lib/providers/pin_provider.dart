import 'package:flutter/material.dart';
import '../services/pin_service.dart';

class PinProvider extends ChangeNotifier {
  final PinService _pinService = PinService();

  bool _isAuthenticated = false;
  bool _isPinEnabled = false;
  bool _shouldShowPinScreen = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isPinEnabled => _isPinEnabled;
  bool get shouldShowPinScreen => _shouldShowPinScreen;

  /// Inicializa o provider verificando se o PIN está habilitado
  Future<void> initialize() async {
    _isPinEnabled = await _pinService.isPinEnabled();

    // Se o PIN está habilitado, o usuário precisa se autenticar
    if (_isPinEnabled) {
      _isAuthenticated = false;
      _shouldShowPinScreen = true;
    } else {
      _isAuthenticated = true;
      _shouldShowPinScreen = false;
    }

    notifyListeners();
  }

  /// Habilita o PIN com o código fornecido
  Future<bool> enablePin(String pin) async {
    try {
      await _pinService.savePin(pin);
      _isPinEnabled = true;
      _isAuthenticated = true;
      _shouldShowPinScreen = false;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Desabilita o PIN
  Future<bool> disablePin(String currentPin) async {
    try {
      final isValid = await _pinService.verifyPin(currentPin);
      if (!isValid) return false;

      await _pinService.removePin();
      _isPinEnabled = false;
      _isAuthenticated = true;
      _shouldShowPinScreen = false;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Autentica com o PIN
  Future<bool> authenticate(String pin) async {
    try {
      final isValid = await _pinService.verifyPin(pin);
      if (isValid) {
        _isAuthenticated = true;
        _shouldShowPinScreen = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Força a exibição da tela de PIN (quando o app volta do background)
  void requireAuthentication() {
    if (_isPinEnabled) {
      _isAuthenticated = false;
      _shouldShowPinScreen = true;
      notifyListeners();
    }
  }

  /// Verifica se o PIN está habilitado
  Future<bool> checkPinEnabled() async {
    _isPinEnabled = await _pinService.isPinEnabled();
    notifyListeners();
    return _isPinEnabled;
  }

  /// Altera o PIN
  Future<bool> changePin(String currentPin, String newPin) async {
    try {
      final isValid = await _pinService.verifyPin(currentPin);
      if (!isValid) return false;

      await _pinService.savePin(newPin);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
