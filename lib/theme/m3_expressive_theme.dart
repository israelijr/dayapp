import 'package:flutter/material.dart';

/// Tema Material Design 3 Expressive para o DayApp
/// Versão enxuta: expõe `getLightTheme` e `getDarkTheme`.
class M3ExpressiveTheme {
  // Seed color principal do DayApp (roxo)
  static const Color seedColor = Color(0xFFB388FF);

  /// Retorna o tema claro com estilo M3 Expressive
  static ThemeData getLightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    );

    return ThemeData.from(colorScheme: colorScheme);
  }

  /// Retorna o tema escuro com estilo M3 Expressive
  static ThemeData getDarkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    );

    return ThemeData.from(colorScheme: colorScheme);
  }
}

// Classe imutável com cores do branding para uso em telas e estilos.
class _AppColors {
  const _AppColors();

  // Primárias
  final Color primary = const Color(0xFFB388FF);
  final Color primaryVariant = const Color(0xFF5E35B1);

  // Tons de fundo/brand
  final Color backgroundLight = const Color(0xFFF5E8FA);
  final Color lilacLight = const Color(0xFFE8D5F0);

  // Paleta adicional usada no splash/decoração
  final Color purple700 = const Color(0xFF7B2CBF);
  final Color purple600 = const Color(0xFF9D4EDD);
  final Color purple300 = const Color(0xFFC77DFF);
  final Color purple200 = const Color(0xFFE0AAFF);
}

// Conveniência para importadores: `AppColors.primary`
class AppColors {
  static const _AppColors _app = _AppColors();
  static Color get primary => _app.primary;
  static Color get primaryVariant => _app.primaryVariant;
  static Color get backgroundLight => _app.backgroundLight;
  static Color get lilacLight => _app.lilacLight;
  static Color get purple700 => _app.purple700;
  static Color get purple600 => _app.purple600;
  static Color get purple300 => _app.purple300;
  static Color get purple200 => _app.purple200;
}
