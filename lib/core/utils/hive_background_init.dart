import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Initialize Hive.

Future<void> initHiveForBackground() async {
  try {
    final dir = await getApplicationSupportDirectory();
    await Hive.initFlutter(dir.path);
  } catch (e, st) {
    debugPrint('initHiveForBackground: failed to get app support dir: $e');
    debugPrint('$st');
    await Hive.initFlutter();
  }
}
