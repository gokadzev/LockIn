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
