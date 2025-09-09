import 'package:flutter/material.dart';
import 'package:lockin/themes/text_theme.dart';

final scheme = ColorScheme.fromSeed(
  seedColor: Colors.brown,
  brightness: Brightness.dark,
);

// A single, theme-driven color for subtle box/chip backgrounds used across cards.
final boxDecorationColor = scheme.onSurface.withValues(alpha: 0.1);

ThemeData getAppTheme() {
  // Adapt the static appTextTheme to use semantic colors from the generated scheme.
  final effectiveTextTheme = appTextTheme.copyWith(
    headlineSmall: appTextTheme.headlineSmall?.copyWith(
      color: scheme.onSurface,
    ),
    titleLarge: appTextTheme.titleLarge?.copyWith(color: scheme.onSurface),
    titleMedium: appTextTheme.titleMedium?.copyWith(color: scheme.onSurface),
    bodyLarge: appTextTheme.bodyLarge?.copyWith(color: scheme.onSurface),
    bodyMedium: appTextTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    ),
    bodySmall: appTextTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
    labelLarge: appTextTheme.labelLarge?.copyWith(color: scheme.onPrimary),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: effectiveTextTheme,
    fontFamily: 'Lato',
    scaffoldBackgroundColor: scheme.surface,
    canvasColor: scheme.surface,
    // Global typography tweaks
    visualDensity: VisualDensity.compact,
    cardTheme: CardThemeData(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: scheme.surfaceContainerHighest,
      surfaceTintColor: scheme.primaryContainer,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 24,
        color: scheme.onSurface,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: scheme.surface,
      selectedItemColor: scheme.primary,
      unselectedItemColor: scheme.onSurfaceVariant,
      showUnselectedLabels: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: scheme.onSurface.withValues(alpha: 0.6)),
    ),
  );
}
