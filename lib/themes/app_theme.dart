/*
 *     Copyright (C) 2026 Valeri Gokadze
 *
 *     LockIn is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     LockIn is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:lockin/themes/text_theme.dart';

final scheme = ColorScheme.fromSeed(
  seedColor: Colors.brown,
  brightness: Brightness.dark,
);

// A single, theme-driven color for subtle box/chip backgrounds used across cards.
final boxDecorationColor = scheme.onSurface.withValues(alpha: 0.1);

ThemeData getAppTheme({
  ColorScheme? lightColorScheme,
  ColorScheme? darkColorScheme,
}) {
  // Regenerate schemes with proper brightness to ensure surface containers get correct distinct colors
  final effectiveScheme = darkColorScheme != null
      ? ColorScheme.fromSeed(
          seedColor: Color(darkColorScheme.primary.toARGB32()),
          brightness: Brightness.dark,
        )
      : scheme;

  // Adapt the static appTextTheme to use semantic colors from the generated scheme.
  final effectiveTextTheme = appTextTheme.copyWith(
    headlineSmall: appTextTheme.headlineSmall?.copyWith(
      color: effectiveScheme.onSurface,
    ),
    titleLarge: appTextTheme.titleLarge?.copyWith(
      color: effectiveScheme.onSurface,
    ),
    titleMedium: appTextTheme.titleMedium?.copyWith(
      color: effectiveScheme.onSurface,
    ),
    bodyLarge: appTextTheme.bodyLarge?.copyWith(
      color: effectiveScheme.onSurface,
    ),
    bodyMedium: appTextTheme.bodyMedium?.copyWith(
      color: effectiveScheme.onSurfaceVariant,
    ),
    bodySmall: appTextTheme.bodySmall?.copyWith(
      color: effectiveScheme.onSurfaceVariant,
    ),
    labelLarge: appTextTheme.labelLarge?.copyWith(
      color: effectiveScheme.onPrimary,
    ),
    labelSmall: appTextTheme.labelSmall?.copyWith(
      color: effectiveScheme.onSurface,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: effectiveScheme,
    textTheme: effectiveTextTheme,
    fontFamily: 'Lato',
    scaffoldBackgroundColor: effectiveScheme.surface,
    canvasColor: effectiveScheme.surface,
    // Global typography tweaks
    visualDensity: VisualDensity.compact,
    cardTheme: CardThemeData(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: effectiveScheme.surfaceContainerHighest,
      surfaceTintColor: effectiveScheme.primaryContainer,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: effectiveScheme.onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 24,
        color: effectiveScheme.onSurface,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: effectiveScheme.primary,
      foregroundColor: effectiveScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: effectiveScheme.surface,
      selectedItemColor: effectiveScheme.primary,
      unselectedItemColor: effectiveScheme.onSurfaceVariant,
      showUnselectedLabels: true,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      indicatorShape: const StadiumBorder(),
      indicatorColor: effectiveScheme.secondaryContainer.withAlpha(140),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return effectiveTextTheme.labelSmall?.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: states.contains(WidgetState.selected)
              ? effectiveScheme.onSurface
              : effectiveScheme.onSurface.withAlpha(170),
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(size: 24, color: effectiveScheme.onSurface);
        }
        return IconThemeData(
          size: 22,
          color: effectiveScheme.onSurface.withAlpha(170),
        );
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: effectiveScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(
        color: effectiveScheme.onSurface.withValues(alpha: 0.6),
      ),
    ),
  );
}
