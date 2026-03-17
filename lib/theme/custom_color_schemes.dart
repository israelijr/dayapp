// Esquemas de cores personalizados do DayApp
// Contém os esquemas nas variantes Light e Dark
import 'package:flutter/material.dart';

// Observação: as colunas da tabela foram mapeadas para os campos do ColorScheme
// do Flutter (SurfaceDim -> surfaceContainerHighest, Surface -> surface, etc.).

class CustomColorSchemes {
  // Chaves de família dos esquemas personalizados
  static const String relvaFamilyKey = 'relva';
  static const String outonoFamilyKey = 'outono';
  static const String ceuFamilyKey = 'ceu';
  static const String confortFamilyKey = 'confort';
  static const String sunsetFamilyKey = 'sunset';

  static const List<String> familyKeys = [
    relvaFamilyKey,
    outonoFamilyKey,
    ceuFamilyKey,
    confortFamilyKey,
    sunsetFamilyKey,
  ];

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

  // Céu - Light
  static final ColorScheme ceuLight = const ColorScheme.light().copyWith(
    primary: const Color(0xFF415F91),
    secondary: const Color(0xFF565F71),
    tertiary: const Color(0xFF705575),
    error: const Color(0xFFBA1A1A),
    primaryContainer: const Color.fromRGBO(157, 188, 253, 1),
    secondaryContainer: const Color.fromARGB(255, 99, 138, 255),
    //secondaryContainer: const Color.fromARGB(255, 3, 52, 197),
    tertiaryContainer: const Color(0xFFFAD8FD),
    errorContainer: const Color(0xFFFFDAD6),
    surfaceContainerHighest: const Color(0xFFE2E2E9),
    surface: const Color(0xFFF9F9FF),
    inverseSurface: const Color(0xFF2E3036),
  );

  // Céu - Dark
  static final ColorScheme ceuDark = const ColorScheme.dark().copyWith(
    primary: const Color(0xFFADC6FF),
    secondary: const Color(0xFFBFC6DC),
    tertiary: const Color(0xFFDEBCDF),
    error: const Color(0xFFFFB4AB),
    primaryContainer: const Color(0xFF2B4678),
    secondaryContainer: const Color(0xFF3F4759),
    tertiaryContainer: const Color(0xFF583E5B),
    errorContainer: const Color(0xFF93000A),
    surfaceContainerHighest: const Color(0xFF282A2F),
    surface: const Color(0xFF111318),
    inverseSurface: const Color(0xFFE2E2E9),
  );

  // Confort - Light
  // primary: usar #665E40 (marrom quente escuro, ~6.3:1 contra branco)
  // em vez do amarelo claro original #FFF0BA que não tem contraste suficiente
  static final ColorScheme confortLight = const ColorScheme.light().copyWith(
    primary: const Color(0xFF665E40),
    onPrimary: Colors.white,
    secondary: const Color(0xFF43664E),
    tertiary: const Color(0xFF3B6070),
    error: const Color(0xFFBA1A1A),
    primaryContainer: const Color(0xFFF8E287),
    onPrimaryContainer: const Color(0xFF1C1400),
    secondaryContainer: const Color(0xFFEEE2BC),
    tertiaryContainer: const Color(0xFFC5ECCE),
    errorContainer: const Color(0xFFFFDAD6),
    surfaceContainerHighest: const Color(0xFFEEE8DA),
    surface: const Color(0xFFFFF9EE),
    inverseSurface: const Color(0xFF333027),
  );

  // Confort - Dark
  static final ColorScheme confortDark = const ColorScheme.dark().copyWith(
    primary: const Color(0xFFDBC66E),
    secondary: const Color(0xFFD1C6A1),
    tertiary: const Color(0xFFA9D0B3),
    error: const Color(0xFFFFB4AB),
    primaryContainer: const Color(0xFF534600),
    secondaryContainer: const Color(0xFF4E472A),
    tertiaryContainer: const Color(0xFF2C4E38),
    errorContainer: const Color(0xFF93000A),
    surfaceContainerHighest: const Color(0xFF38352B),
    surface: const Color(0xFF15130B),
    inverseSurface: const Color(0xFFE8E2D4),
  );

  // Sunset - Light
  static final ColorScheme sunsetLight = const ColorScheme.light().copyWith(
    primary: const Color(0xFF9C4330),
    onPrimary: Colors.white,
    secondary: const Color(0xFF77574E),
    tertiary: const Color(0xFF6C5D2F),
    error: const Color(0xFFBA1A1A),
    primaryContainer: const Color(0xFFFFDAD3),
    onPrimaryContainer: const Color(0xFF3B0A02),
    secondaryContainer: const Color(0xFFFFDBD1),
    tertiaryContainer: const Color(0xFFF5E1A7),
    errorContainer: const Color(0xFFFFDAD6),
    surfaceContainerHighest: const Color(0xFFEDE0DC),
    surface: const Color(0xFFFFFBFF),
    inverseSurface: const Color(0xFF3C2A26),
  );

  // Sunset - Dark
  static final ColorScheme sunsetDark = const ColorScheme.dark().copyWith(
    primary: const Color(0xFFFFB4A3),
    secondary: const Color(0xFFE7BDB2),
    tertiary: const Color(0xFFD8C58D),
    error: const Color(0xFFFFB4AB),
    primaryContainer: const Color(0xFF7D2C1B),
    secondaryContainer: const Color(0xFF5D4037),
    tertiaryContainer: const Color(0xFF534619),
    errorContainer: const Color(0xFF93000A),
    surfaceContainerHighest: const Color(0xFF2E2220),
    surface: const Color(0xFF201A18),
    inverseSurface: const Color(0xFFF1DFDA),
  );

  // Mapa de fácil acesso aos esquemas criados
  static final Map<String, ColorScheme> customSchemes = {
    'relvaLight': relvaLight,
    'relvaDark': relvaDark,
    'outonoLight': outonoLight,
    'outonoDark': outonoDark,
    'ceuLight': ceuLight,
    'ceuDark': ceuDark,
    'confortLight': confortLight,
    'confortDark': confortDark,
    'sunsetLight': sunsetLight,
    'sunsetDark': sunsetDark,
  };

  // --- Utilitários de família ---

  /// Normaliza qualquer chave (antiga ou nova) para a chave de família.
  static String? normalizeFamilyKey(String? key) {
    switch (key) {
      case relvaFamilyKey:
      case 'relvaLight':
      case 'relvaDark':
        return relvaFamilyKey;
      case outonoFamilyKey:
      case 'outonoLight':
      case 'outonoDark':
        return outonoFamilyKey;
      case ceuFamilyKey:
      case 'ceuLight':
      case 'ceuDark':
        return ceuFamilyKey;
      case confortFamilyKey:
      case 'confortLight':
      case 'confortDark':
        return confortFamilyKey;
      case sunsetFamilyKey:
      case 'sunsetLight':
      case 'sunsetDark':
        return sunsetFamilyKey;
      default:
        return null;
    }
  }

  static String lightKeyForFamily(String familyKey) {
    switch (familyKey) {
      case relvaFamilyKey:
        return 'relvaLight';
      case outonoFamilyKey:
        return 'outonoLight';
      case ceuFamilyKey:
        return 'ceuLight';
      case confortFamilyKey:
        return 'confortLight';
      case sunsetFamilyKey:
        return 'sunsetLight';
      default:
        return familyKey;
    }
  }

  static String darkKeyForFamily(String familyKey) {
    switch (familyKey) {
      case relvaFamilyKey:
        return 'relvaDark';
      case outonoFamilyKey:
        return 'outonoDark';
      case ceuFamilyKey:
        return 'ceuDark';
      case confortFamilyKey:
        return 'confortDark';
      case sunsetFamilyKey:
        return 'sunsetDark';
      default:
        return familyKey;
    }
  }

  /// Retorna o ColorScheme correto para a família e brilho informados.
  static ColorScheme? getSchemeForFamily(
    String? familyKey,
    Brightness brightness,
  ) {
    final normalizedKey = normalizeFamilyKey(familyKey);
    if (normalizedKey == null) return null;

    final schemeKey = brightness == Brightness.dark
        ? darkKeyForFamily(normalizedKey)
        : lightKeyForFamily(normalizedKey);

    return customSchemes[schemeKey];
  }
}
