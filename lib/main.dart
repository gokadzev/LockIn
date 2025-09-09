import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:lockin/background/habit_engagement_task.dart';
import 'package:lockin/config/app_router.dart';
import 'package:lockin/config/app_setup.dart';
import 'package:lockin/themes/app_theme.dart';
import 'package:lockin/widgets/main_navigation.dart';
import 'package:workmanager/workmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await initializeApp();

  await Workmanager().initialize(habitEngagementCallbackDispatcher);
  await Workmanager().registerPeriodicTask(
    habitEngagementTaskName,
    habitEngagementTaskName,
    frequency: const Duration(hours: 24),
    initialDelay: const Duration(minutes: 1),
  );

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
