import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:lockin/config/app_router.dart';
import 'package:lockin/config/app_setup.dart';
import 'package:lockin/core/notifications/notification_background_service.dart';
import 'package:lockin/themes/app_theme.dart';
import 'package:lockin/widgets/main_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await initializeApp();

  // Initialize the new background notification service
  final backgroundManager = NotificationBackgroundManager();
  await backgroundManager.initialize();

  runApp(const ProviderScope(child: LockinApp()));
}

class LockinApp extends StatelessWidget {
  const LockinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lockin Productivity',
      theme: getAppTheme(),
      onGenerateRoute: AppRouter.generateRoute,
      home: const MainNavigation(),
    );
  }
}
