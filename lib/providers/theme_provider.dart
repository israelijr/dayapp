import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.light;
  bool _isLoaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get isLoaded => _isLoaded;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    } else {
      // Se não há prefs, define como light e salva
      _themeMode = ThemeMode.light;
      await prefs.setInt(_themeKey, _themeMode.index);
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  Future<void> waitForLoad() async {
    while (!_isLoaded) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }
}
