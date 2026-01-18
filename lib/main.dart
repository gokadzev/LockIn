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

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/config/app_router.dart';
import 'package:lockin/config/app_setup.dart';
import 'package:lockin/core/notifications/notification_background_service.dart';
import 'package:lockin/features/settings/dynamic_color_provider.dart';
import 'package:lockin/themes/app_theme.dart';
import 'package:lockin/widgets/main_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeApp();

  // Initialize the new background notification service
  final backgroundManager = NotificationBackgroundManager();
  await backgroundManager.initialize();

  runApp(const ProviderScope(child: LockinApp()));
}

class LockinApp extends ConsumerWidget {
  const LockinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicColorEnabled = ref.watch(dynamicColorEnabledProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        // Only use dynamic colors if enabled and available
        final useDynamicColor = dynamicColorEnabled && darkDynamic != null;

        return MaterialApp(
          title: 'Lockin Productivity',
          theme: getAppTheme(
            lightColorScheme: useDynamicColor ? lightDynamic : null,
            darkColorScheme: useDynamicColor ? darkDynamic : null,
          ),
          onGenerateRoute: AppRouter.generateRoute,
          home: const MainNavigation(),
        );
      },
    );
  }
}
