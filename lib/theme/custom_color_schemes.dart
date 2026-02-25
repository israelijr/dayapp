// Arquivo gerado automaticamente: esquemas de cores personalizados
// Contém os esquemas 'Relva' e 'Outono' nas variantes Light e Dark
import 'package:flutter/material.dart';

// Observação: mapeei as colunas da tabela para os campos mais próximos do
// ColorScheme do Flutter (ex.: SurfaceDim -> surfaceVariant, Surface -> surface,
// Inverse Surface -> inverseSurface, Primary Container -> primaryContainer, etc.).

class CustomColorSchemes {
  // Relva - Light
  static final ColorScheme relvaLight = const ColorScheme.light().copyWith(
    primary: const Color(0xFF326941), // Primary
    secondary: const Color(0xFF506352), // Secondary
    tertiary: const Color(0xFF3A656E), // Tertiary
    error: const Color(0xFFBA1A1A), // Error
    primaryContainer: const Color(0xFFB4F1BD), // Primary Container
    secondaryContainer: const Color(0xFFD3E8D2), // Secondary Container
    tertiaryContainer: const Color(0xFFBDEAF5), // Tertiary Container
    errorContainer: const Color(0xFFFFDAD6), // On Error Container (mapeado)
    surfaceContainerHighest: const Color(0xFFD7DBD4), // Surface Dim
    surface: const Color(0xFFF6FBF3), // Surface
    inverseSurface: const Color(0xFF2D322C), // Inverse Surface
  );

  // Relva - Dark
  static final ColorScheme relvaDark = const ColorScheme.dark().copyWith(
    primary: const Color(0xFF99D4A3),
    secondary: const Color(0xFFB7CCB7),
    tertiary: const Color(0xFFA2CED8),
    error: const Color(0xFFFFB4AB),
    primaryContainer: const Color(0xFF18512B),
    secondaryContainer: const Color(0xFF394B3B),
    tertiaryContainer: const Color(0xFF204D55),
    errorContainer: const Color(0xFF24D055),
    surfaceContainerHighest: const Color(0xFF93000A),
    surface: const Color(0xFF101510),
    inverseSurface: const Color(0xFFDFE4DC),
  );

  // Outono - Light
  static final ColorScheme outonoLight = const ColorScheme.light().copyWith(
    primary: const Color(0xFF8F4C38),
    secondary: const Color(0xFF77574E),
    tertiary: const Color(0xFF6C5D2F),
    error: const Color(0xFFBA1A1A),
    primaryContainer: const Color(0xFFFFDBD1),
    secondaryContainer: const Color(0xFFFFDBD1),
    tertiaryContainer: const Color(0xFFF5E1A7),
    errorContainer: const Color(0xFFFFDAD6),
    surface: const Color(0xFFFFF8F6),
    inverseSurface: const Color(0xFF392E2B),
  );

  // Outono - Dark
  static final ColorScheme outonoDark = const ColorScheme.dark().copyWith(
    primary: const Color(0xFFFFB5A0),
    secondary: const Color(0xFFE7BDB2),
    tertiary: const Color(0xFFD8C58D),
    error: const Color(0xFFFFB4AB),
    primaryContainer: const Color(0xFF723523),
    secondaryContainer: const Color(0xFF5D4037),
    tertiaryContainer: const Color(0xFF534619),
    errorContainer: const Color(0xFF93000A),
    surfaceContainerHighest: const Color(0xFF1A110F),
    surface: const Color(0xFF1A110F),
    inverseSurface: const Color(0xFFF1DFDA),
  );

  // Mapa de fácil acesso aos esquemas criados
  static final Map<String, ColorScheme> customSchemes = {
    'relvaLight': relvaLight,
    'relvaDark': relvaDark,
    'outonoLight': outonoLight,
    'outonoDark': outonoDark,
  };
}
