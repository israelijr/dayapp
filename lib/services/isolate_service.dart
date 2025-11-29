import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Serviço para executar operações pesadas em Isolates
/// Evita travar a UI durante processamentos intensivos
class IsolateService {
  // Singleton
  static final IsolateService _instance = IsolateService._internal();
  factory IsolateService() => _instance;
  IsolateService._internal();

  /// Decodifica JSON grande em um Isolate separado
  /// Útil para processar respostas de API ou arquivos JSON grandes
  Future<dynamic> decodeJson(String jsonString) async {
    if (jsonString.length < 10000) {
      // Para strings pequenas, processa na thread principal
      return json.decode(jsonString);
    }
    return compute(_decodeJsonIsolate, jsonString);
  }

  /// Codifica objeto para JSON em um Isolate separado
  Future<String> encodeJson(dynamic object) async {
    return compute(_encodeJsonIsolate, object);
  }

  /// Processa lista de dados com função de transformação
  /// Útil para mapear/filtrar listas grandes
  Future<List<R>> processListInIsolate<T, R>(
    List<T> items,
    R Function(T) transform,
  ) async {
    // Para listas pequenas, processa na thread principal
    if (items.length < 100) {
      return items.map(transform).toList();
    }

    // Para listas grandes, usa Isolate
    // Nota: transform precisa ser uma função de nível superior
    // ou uma função estática para funcionar em Isolates
    return compute(
      _processListIsolate<T, R>,
      _ListProcessParams(items, transform),
    );
  }

  /// Processa texto pesado (busca, formatação, etc.)
  Future<String> processText(
    String text,
    String Function(String) processor,
  ) async {
    if (text.length < 5000) {
      return processor(text);
    }
    return compute(processor, text);
  }

  /// Calcula estatísticas de uma lista de números
  Future<Map<String, double>> calculateStatistics(List<double> numbers) async {
    if (numbers.length < 1000) {
      return _calculateStatsSync(numbers);
    }
    return compute(_calculateStatsIsolate, numbers);
  }

  /// Busca texto em uma lista grande de strings
  Future<List<int>> searchInList(
    List<String> items,
    String query, {
    bool caseSensitive = false,
  }) async {
    final params = _SearchParams(items, query, caseSensitive);
    if (items.length < 500) {
      return _searchInListSync(params);
    }
    return compute(_searchInListIsolate, params);
  }
}

// === Funções de nível superior para Isolates ===
// (Precisam ser funções de nível superior ou estáticas)

dynamic _decodeJsonIsolate(String jsonString) {
  return json.decode(jsonString);
}

String _encodeJsonIsolate(dynamic object) {
  return json.encode(object);
}

List<R> _processListIsolate<T, R>(_ListProcessParams<T, R> params) {
  return params.items.map(params.transform).toList();
}

Map<String, double> _calculateStatsIsolate(List<double> numbers) {
  return _calculateStatsSync(numbers);
}

Map<String, double> _calculateStatsSync(List<double> numbers) {
  if (numbers.isEmpty) {
    return {'count': 0, 'sum': 0, 'average': 0, 'min': 0, 'max': 0, 'range': 0};
  }

  double sum = 0;
  double min = numbers[0];
  double max = numbers[0];

  for (final n in numbers) {
    sum += n;
    if (n < min) min = n;
    if (n > max) max = n;
  }

  return {
    'count': numbers.length.toDouble(),
    'sum': sum,
    'average': sum / numbers.length,
    'min': min,
    'max': max,
    'range': max - min,
  };
}

List<int> _searchInListIsolate(_SearchParams params) {
  return _searchInListSync(params);
}

List<int> _searchInListSync(_SearchParams params) {
  final results = <int>[];
  final query = params.caseSensitive
      ? params.query
      : params.query.toLowerCase();

  for (int i = 0; i < params.items.length; i++) {
    final item = params.caseSensitive
        ? params.items[i]
        : params.items[i].toLowerCase();
    if (item.contains(query)) {
      results.add(i);
    }
  }

  return results;
}

// === Classes auxiliares para parâmetros ===

class _ListProcessParams<T, R> {
  final List<T> items;
  final R Function(T) transform;

  _ListProcessParams(this.items, this.transform);
}

class _SearchParams {
  final List<String> items;
  final String query;
  final bool caseSensitive;

  _SearchParams(this.items, this.query, this.caseSensitive);
}
