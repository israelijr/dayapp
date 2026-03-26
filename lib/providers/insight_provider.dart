import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/insight.dart';
import '../services/insight_service.dart';

/// Provider que expõe os insights gerados para a Home.
///
/// Gerencia:
/// - carregamento e cache de insights
/// - ciclo de vida: expiração automática (1 dia) e cooldown (15 dias) após dispensa
/// - dispensa manual pelo usuário
/// - modo desenvolvimento (devMode via kDebugMode): exibe todos os insights sem filtro
class InsightProvider with ChangeNotifier {
  final InsightService _service = InsightService();

  List<Insight> _insights = [];
  bool _isLoading = false;
  String? _lastUserId;

  // Prefixos de chaves no SharedPreferences
  static const String _shownAtPrefix = 'insight_shown_';
  static const String _dismissedAtPrefix = 'insight_dismissed_';

  /// Duração que um insight permanece visível antes de desaparecer automaticamente.
  /// 1 dia para testes; altere para Duration(days: 2) na produção.
  static const Duration _visibilityDuration = Duration(days: 1);

  /// Período de cooldown após dispensa para o insight reaparecer.
  static const Duration _cooldownDuration = Duration(days: 15);

  /// Em modo debug (kDebugMode), todos os insights são exibidos sem verificação de tempo.
  bool get devMode => kDebugMode;

  /// Lista de insights disponíveis (já filtrados para exibição).
  List<Insight> get insights => List.unmodifiable(_insights);

  /// Indica se há um carregamento em andamento.
  bool get isLoading => _isLoading;

  // ---------------------------------------------------------------------------
  // API Pública
  // ---------------------------------------------------------------------------

  /// Carrega os insights para o usuário aplicando as regras de ciclo de vida.
  Future<void> loadInsights(String userId) async {
    if (_isLoading && _lastUserId == userId) return;
    _isLoading = true;
    _lastUserId = userId;
    notifyListeners();

    try {
      final all = await _service.getInsights(userId);
      _insights = await _applyLifecycle(userId, all);
    } catch (e) {
      // Insights não são críticos — falha silenciosa
      _insights = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Força recálculo descartando o cache do serviço.
  Future<void> refresh(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final all = await _service.getInsights(userId, forceRefresh: true);
      _insights = await _applyLifecycle(userId, all);
    } catch (e) {
      _insights = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Dispensa manualmente um insight (registra timestamp de dispensa).
  /// O insight não reaparece por [_cooldownDuration] (15 dias).
  Future<void> dismissInsight(String userId, InsightType type) async {
    // Remove da lista local imediatamente para feedback instantâneo
    _insights = _insights.where((i) => i.type != type).toList();
    notifyListeners();

    if (devMode) return; // Em dev mode não persiste dispensa

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _dismissedKey(userId, type),
      DateTime.now().millisecondsSinceEpoch,
    );
    await prefs.remove(_shownKey(userId, type));
  }

  // ---------------------------------------------------------------------------
  // Lógica de ciclo de vida
  // ---------------------------------------------------------------------------

  Future<List<Insight>> _applyLifecycle(
    String userId,
    List<Insight> allInsights,
  ) async {
    // Em modo de desenvolvimento: exibe tudo, sem verificação de tempo.
    if (devMode) return allInsights;

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final visible = <Insight>[];

    for (final insight in allInsights) {
      final shownKey = _shownKey(userId, insight.type);
      final dismissedKey = _dismissedKey(userId, insight.type);

      final dismissedMs = prefs.getInt(dismissedKey);

      if (dismissedMs != null) {
        // Insight foi dispensado (manualmente ou auto-expirado)
        final dismissed = DateTime.fromMillisecondsSinceEpoch(dismissedMs);
        if (now.difference(dismissed) >= _cooldownDuration) {
          // Cooldown encerrou: limpa e reapresenta
          await prefs.remove(dismissedKey);
          await prefs.setInt(shownKey, now.millisecondsSinceEpoch);
          visible.add(insight);
        }
        // Else: ainda em cooldown → não exibe
      } else {
        // Nunca foi dispensado
        final shownMs = prefs.getInt(shownKey);
        if (shownMs == null) {
          // Primeira exibição: registra timestamp
          await prefs.setInt(shownKey, now.millisecondsSinceEpoch);
          visible.add(insight);
        } else {
          final shownAt = DateTime.fromMillisecondsSinceEpoch(shownMs);
          if (now.difference(shownAt) < _visibilityDuration) {
            // Ainda dentro do período de visibilidade
            visible.add(insight);
          } else {
            // Auto-expirou: marca como dispensado para iniciar o cooldown
            await prefs.setInt(
              dismissedKey,
              shownAt.add(_visibilityDuration).millisecondsSinceEpoch,
            );
            await prefs.remove(shownKey);
            // Não adiciona à lista visível
          }
        }
      }
    }

    return visible;
  }

  // ---------------------------------------------------------------------------
  // Helpers de chave para SharedPreferences
  // ---------------------------------------------------------------------------

  String _shownKey(String userId, InsightType type) =>
      '$_shownAtPrefix${userId}_${type.value}';

  String _dismissedKey(String userId, InsightType type) =>
      '$_dismissedAtPrefix${userId}_${type.value}';
}
