import 'package:shared_preferences/shared_preferences.dart';

/// Serviço para gerenciar o bloqueio quando o app volta do segundo plano
class InactivityService {
  static final InactivityService _instance = InactivityService._internal();
  factory InactivityService() => _instance;
  InactivityService._internal();

  static const String _backgroundLockTimeoutKey =
      'background_lock_timeout_seconds';

  /// Tempo padrão de bloqueio em segundo plano (em segundos)
  /// 0 significa imediato
  static const int defaultBackgroundTimeoutSeconds = 0;

  /// Obtém o tempo de bloqueio em segundo plano configurado (em segundos)
  Future<int> getBackgroundLockTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_backgroundLockTimeoutKey) ??
        defaultBackgroundTimeoutSeconds;
  }

  /// Define o tempo de bloqueio em segundo plano (em segundos)
  Future<void> setBackgroundLockTimeout(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_backgroundLockTimeoutKey, seconds);
  }

  /// Opções rápidas de tempo de bloqueio em segundo plano (em segundos)
  static const List<int> backgroundTimeoutOptions = [
    0, // Imediato
    15, // 15 segundos
    30, // 30 segundos
    60, // 1 minuto
    300, // 5 minutos
    600, // 10 minutos
    1800, // 30 minutos
    3600, // 1 hora
  ];

  /// Retorna o texto descritivo para opções de bloqueio em segundo plano
  static String getBackgroundTimeoutLabel(int seconds) {
    if (seconds == 0) return 'Imediatamente';
    if (seconds < 60) return '$seconds segundos';
    if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      if (remainingSeconds == 0) {
        return minutes == 1 ? '1 minuto' : '$minutes minutos';
      }
      return '$minutes min $remainingSeconds seg';
    }
    final hours = seconds ~/ 3600;
    final remainingMinutes = (seconds % 3600) ~/ 60;
    if (remainingMinutes == 0) {
      return hours == 1 ? '1 hora' : '$hours horas';
    }
    return '$hours h $remainingMinutes min';
  }
}
