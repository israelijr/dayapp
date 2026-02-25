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

  /// Define e persiste a seleção
  Future<void> setSelection(String sel) async {
    _selection = sel;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, sel);
    _applySelection();
  }
}
