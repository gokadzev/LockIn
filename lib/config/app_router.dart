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
import 'package:lockin/features/recommendations/recommendations_page.dart';
import 'package:lockin/features/settings/settings_home.dart';
import 'package:lockin/features/xp/xp_tab_screen.dart';
import 'package:lockin/widgets/main_navigation.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const MainNavigation());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsHome());
      case '/xp':
        return MaterialPageRoute(builder: (_) => const XPTabScreen());
      case '/recommendations':
        return MaterialPageRoute(builder: (_) => const SuggestionsPage());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
