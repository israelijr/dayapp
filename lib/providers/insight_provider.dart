import 'package:flutter/foundation.dart';

import '../models/insight.dart';
import '../services/insight_service.dart';

/// Provider que expõe os insights gerados para a Home.
///
/// Conecta o [InsightService] ao widget tree via [ChangeNotifier].
/// Registrar no MultiProvider do main.dart antes de usar.
class InsightProvider with ChangeNotifier {
  final InsightService _service = InsightService();

  List<Insight> _insights = [];
  bool _isLoading = false;
  String? _lastUserId;

  /// Lista de insights disponíveis (já filtrados e priorizados pelo serviço).
  List<Insight> get insights => List.unmodifiable(_insights);

  /// Indica se há um carregamento em andamento.
  bool get isLoading => _isLoading;

  /// Carrega (ou retorna do cache) os insights para o usuário.
  ///
  /// É seguro chamar múltiplas vezes — ignora chamadas duplicadas enquanto
  /// um carregamento já estiver em andamento para o mesmo userId.
  Future<void> loadInsights(String userId) async {
    if (_isLoading && _lastUserId == userId) return;

    _isLoading = true;
    _lastUserId = userId;
    notifyListeners();

    try {
      _insights = await _service.getInsights(userId);
    } catch (e) {
      // Falha silenciosa: insights não são críticos para o funcionamento do app
      _insights = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Força o recálculo descartando o cache de 24h.
  Future<void> refresh(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _insights = await _service.getInsights(userId, forceRefresh: true);
    } catch (e) {
      // Silencia erro — recalculo falhou, mantém lista atual
      _insights = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
