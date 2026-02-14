import 'dart:io';

import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço para gerenciar verificações e configurações de otimização de bateria.
///
/// Algumas funcionalidades do app (como notificações de engajamento) requerem
/// que a otimização de bateria seja desabilitada para funcionar corretamente.
class BatteryOptimizationService {
  static final BatteryOptimizationService _instance =
      BatteryOptimizationService._internal();
  factory BatteryOptimizationService() => _instance;
  BatteryOptimizationService._internal();

  // Chave para armazenar se o usuário já foi informado sobre as configurações
  static const String _hasShownBatteryDialogKey = 'has_shown_battery_dialog';
  static const String _dismissedBatteryDialogKey = 'dismissed_battery_dialog';

  /// Verifica se a otimização de bateria está desabilitada para o app
  ///
  /// Retorna true se a otimização está desabilitada (app pode rodar em background)
  /// Retorna false se a otimização está habilitada (app pode ser restringido)
  /// Retorna null se não foi possível verificar
  Future<bool?> isBatteryOptimizationDisabled() async {
    // Só funciona em Android
    if (kIsWeb || !Platform.isAndroid) {
      return true;
    }

    try {
      return await DisableBatteryOptimization.isBatteryOptimizationDisabled;
    } catch (e) {
      return null;
    }
  }

  /// Abre a tela de configurações de otimização de bateria do sistema
  ///
  /// Retorna true se conseguiu abrir as configurações
  Future<bool> openBatteryOptimizationSettings() async {
    if (kIsWeb || !Platform.isAndroid) {
      return false;
    }

    try {
      final result =
          await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Solicita ao sistema desabilitar a otimização de bateria
  ///
  /// Mostra um dialog do sistema pedindo permissão
  Future<bool> requestDisableBatteryOptimization() async {
    if (kIsWeb || !Platform.isAndroid) {
      return false;
    }

    try {
      final result =
          await DisableBatteryOptimization.showDisableManufacturerBatteryOptimizationSettings(
            'O DayApp precisa enviar notificações',
            'Para receber lembretes de registrar suas histórias, '
                'desabilite a otimização de bateria para o app.',
          );
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Verifica se o usuário já foi informado sobre as configurações de bateria
  Future<bool> hasShownBatteryDialog() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasShownBatteryDialogKey) ?? false;
  }

  /// Marca que o usuário já foi informado sobre as configurações de bateria
  Future<void> markBatteryDialogAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasShownBatteryDialogKey, true);
  }

  /// Verifica se o usuário escolheu não ver mais o aviso
  Future<bool> hasUserDismissedDialog() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dismissedBatteryDialogKey) ?? false;
  }

  /// Marca que o usuário escolheu não ver mais o aviso
  Future<void> dismissBatteryDialog() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dismissedBatteryDialogKey, true);
  }

  /// Reseta as preferências de aviso de bateria
  Future<void> resetBatteryDialogPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasShownBatteryDialogKey);
    await prefs.remove(_dismissedBatteryDialogKey);
  }

  /// Verifica se deve mostrar o aviso de otimização de bateria
  ///
  /// Retorna true se:
  /// - Estamos em Android
  /// - A otimização de bateria está habilitada (restringindo o app)
  /// - O usuário ainda não dispensou o aviso
  Future<bool> shouldShowBatteryWarning() async {
    if (kIsWeb || !Platform.isAndroid) {
      return false;
    }

    // Verifica se o usuário já dispensou o aviso
    final dismissed = await hasUserDismissedDialog();
    if (dismissed) {
      return false;
    }

    // Verifica se a otimização está habilitada
    final isDisabled = await isBatteryOptimizationDisabled();
    return isDisabled == false;
  }
}
