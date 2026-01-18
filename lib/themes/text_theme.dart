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
import 'package:lockin/themes/app_theme.dart';

final TextTheme appTextTheme = ThemeData.dark().textTheme
    .copyWith(
      // App bar / large headings
      headlineSmall: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w900,
        color: scheme.onSurface,
        letterSpacing: 1.1,
      ),
      // Card titles (e.g. goal/task titles)
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      // Secondary card titles / medium headings
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      // Primary body text
      bodyLarge: TextStyle(
        fontSize: 14,
        color: scheme.onSurface.withValues(alpha: 0.85),
      ),
      // Secondary body / captions
      bodyMedium: TextStyle(
        fontSize: 13,
        color: scheme.onSurface.withValues(alpha: 0.75),
      ),
      // Small labels / chips
      bodySmall: TextStyle(
        fontSize: 12,
        color: scheme.onSurface.withValues(alpha: 0.75),
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: scheme.onPrimary,
      ),
    )
    .apply(fontFamily: 'Lato');
