import 'package:flutter/material.dart';
import '../services/pin_service.dart';

class PinProvider extends ChangeNotifier {
  final PinService _pinService = PinService();

  bool _isAuthenticated = false;
  bool _isPinEnabled = false;
  bool _shouldShowPinScreen = false;
  bool _isUserLoggedIn = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isPinEnabled => _isPinEnabled;
  bool get shouldShowPinScreen => _shouldShowPinScreen;

  // Flag para evitar loop de bloqueio durante autenticação biométrica
  bool _isAuthenticatingWithBiometrics = false;
  bool get isAuthenticatingWithBiometrics => _isAuthenticatingWithBiometrics;
  set isAuthenticatingWithBiometrics(bool value) {
    _isAuthenticatingWithBiometrics = value;
    // Não precisa notificar listeners para isso, é apenas controle interno/externo
  }

  // Setters públicos para controle direto (usado por biometria)
  set isAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  set shouldShowPinScreen(bool value) {
    _shouldShowPinScreen = value;
    notifyListeners();
  }

  /// Método público para autenticação por biometria
  void authenticateWithBiometric() {
    _isAuthenticated = true;
    _shouldShowPinScreen = false;
    // Não resetamos a flag aqui. Deixamos o main.dart resetar quando consumir o evento
    // ou o LockScreen resetar em caso de erro.
    notifyListeners();
  }

  /// Inicializa o provider verificando se o PIN está habilitado
  /// Requer que o status de login do usuário seja informado
  Future<void> initialize({bool isUserLoggedIn = false}) async {
    _isUserLoggedIn = isUserLoggedIn;
    _isPinEnabled = await _pinService.isPinEnabled();

    // Só mostra tela de PIN se o usuário estiver logado E o PIN estiver habilitado
    if (_isUserLoggedIn && _isPinEnabled) {
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
    // Só exige autenticação se o usuário estiver logado E o PIN estiver habilitado
    if (_isUserLoggedIn && _isPinEnabled) {
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

  /// Atualiza o status de login do usuário
  /// Deve ser chamado quando o usuário faz login ou logout
  /// [isLoggedIn] - se o usuário está logado
  /// [skipPinCheck] - se true, não pede PIN imediatamente (útil após login manual)
  void updateUserLoginStatus(bool isLoggedIn, {bool skipPinCheck = false}) {
    _isUserLoggedIn = isLoggedIn;

    // Se o usuário fez logout, limpa a autenticação do PIN
    if (!isLoggedIn) {
      _isAuthenticated = true;
      _shouldShowPinScreen = false;
    } else if (_isPinEnabled && !skipPinCheck) {
      // Se o usuário fez login e o PIN está habilitado, requer autenticação
      // (mas não imediatamente após login manual)
      _isAuthenticated = false;
      _shouldShowPinScreen = true;
    } else {
      // Login manual ou PIN não habilitado - usuário já está autenticado
      _isAuthenticated = true;
      _shouldShowPinScreen = false;
    }

    notifyListeners();
  }
}
