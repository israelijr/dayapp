import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço para gerenciar o tempo de inatividade do app
/// Controla quando o app deve ser bloqueado por falta de atividade
class InactivityService {
  static final InactivityService _instance = InactivityService._internal();
  factory InactivityService() => _instance;
  InactivityService._internal();

  static const String _inactivityTimeoutKey = 'inactivity_timeout_minutes';
  static const String _lastActivityTimeKey = 'last_activity_time';

  Timer? _inactivityTimer;
  DateTime? _lastActivityTime;
  VoidCallback? _onInactivityTimeout;

  /// Tempo padrão de inatividade (em minutos)
  static const int defaultTimeoutMinutes = 5;

  /// Inicializa o serviço de inatividade
  Future<void> initialize({required VoidCallback onTimeout}) async {
    _onInactivityTimeout = onTimeout;
    _lastActivityTime = DateTime.now();
    await _saveLastActivityTime();
  }

  /// Obtém o tempo de inatividade configurado (em minutos)
  Future<int> getInactivityTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_inactivityTimeoutKey) ?? defaultTimeoutMinutes;
  }

  /// Define o tempo de inatividade (em minutos)
  /// Se timeout for 0, desabilita o bloqueio por inatividade
  Future<void> setInactivityTimeout(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_inactivityTimeoutKey, minutes);

    // Reinicia o timer com o novo tempo
    if (minutes > 0) {
      startTimer();
    } else {
      stopTimer();
    }
  }

  /// Registra atividade do usuário
  void recordActivity() {
    _lastActivityTime = DateTime.now();
    _saveLastActivityTime();
    startTimer(); // Reinicia o timer
  }

  /// Inicia o timer de inatividade
  Future<void> startTimer() async {
    stopTimer(); // Para o timer anterior se existir

    final timeoutMinutes = await getInactivityTimeout();

    // Se timeout for 0, não inicia o timer
    if (timeoutMinutes == 0) return;

    final duration = Duration(minutes: timeoutMinutes);

    _inactivityTimer = Timer(duration, () {
      debugPrint('Tempo de inatividade excedido');
      _onInactivityTimeout?.call();
    });

    debugPrint('Timer de inatividade iniciado: $timeoutMinutes minutos');
  }

  /// Para o timer de inatividade
  void stopTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  /// Verifica se o app deve ser bloqueado ao retornar do background
  Future<bool> shouldLockOnResume() async {
    final timeoutMinutes = await getInactivityTimeout();

    // Se timeout for 0, não bloqueia
    if (timeoutMinutes == 0) return false;

    final prefs = await SharedPreferences.getInstance();
    final lastActivityString = prefs.getString(_lastActivityTimeKey);

    if (lastActivityString == null) return true;

    try {
      final lastActivity = DateTime.parse(lastActivityString);
      final now = DateTime.now();
      final difference = now.difference(lastActivity);

      debugPrint(
        'Tempo desde última atividade: ${difference.inMinutes} minutos',
      );

      return difference.inMinutes >= timeoutMinutes;
    } catch (e) {
      debugPrint('Erro ao verificar tempo de inatividade: $e');
      return true;
    }
  }

  /// Salva o tempo da última atividade
  Future<void> _saveLastActivityTime() async {
    if (_lastActivityTime == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _lastActivityTimeKey,
      _lastActivityTime!.toIso8601String(),
    );
  }

  /// Limpa os dados de inatividade
  Future<void> clear() async {
    stopTimer();
    _lastActivityTime = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastActivityTimeKey);
  }

  /// Opções de tempo de inatividade disponíveis
  static const List<int> timeoutOptions = [
    0, // Desabilitado
    1, // 1 minuto
    5, // 5 minutos
    15, // 15 minutos
    30, // 30 minutos
    60, // 1 hora
  ];

  /// Retorna o texto descritivo para cada opção de tempo
  static String getTimeoutLabel(int minutes) {
    if (minutes == 0) return 'Desabilitado';
    if (minutes == 1) return '1 minuto';
    if (minutes < 60) return '$minutes minutos';
    final hours = minutes ~/ 60;
    return hours == 1 ? '1 hora' : '$hours horas';
  }
}
