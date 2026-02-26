import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para gerenciar a seleção de idioma do app.
/// Armazena a preferência em `SharedPreferences`.
class LocaleProvider extends ChangeNotifier {
  static const _prefsKey = 'app_locale_selection';

  /// 'system' | 'en' | 'es'
  String _selection = 'system';
  Locale? _locale; // null = usar padrão do dispositivo

  LocaleProvider();

  String get selection => _selection;
  Locale? get locale => _locale;

  /// Carrega a seleção salva (assíncrono)
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _selection = prefs.getString(_prefsKey) ?? 'system';
    _applySelection(notify: false);
  }

  void _applySelection({bool notify = true}) {
    switch (_selection) {
      case 'en':
        _locale = const Locale('en', 'US');
        break;
      case 'es':
        _locale = const Locale('es', 'ES');
        break;
      case 'system':
      default:
        _locale = null;
    }

    if (notify) notifyListeners();
  }

  /// Define e persiste a seleção.
  ///
  /// Atualiza o estado local **imediatamente** (notificando listeners) e
  /// só depois grava nos _SharedPreferences_. Isso evita que a UI fique
  /// presa no idioma anterior durante o tempo que o armazenamento leva para
  /// completar.
  Future<void> setSelection(String sel) async {
    _selection = sel;
    // aplica antes de gravar, o notify faz com que a árvore (MaterialApp)
    // reconstrua com o novo locale imediatamente.
    _applySelection();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, sel);
    } catch (e) {
      // Silencia erros de escrita - não é crítico para o uso imediato.
    }
  }
}
