import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

/// Safely return an opened Hive box or null if not available.
Box<T>? openBoxIfAvailable<T>(String name) {
  try {
    return Hive.isBoxOpen(name) ? Hive.box<T>(name) : null;
  } catch (e, st) {
    debugPrint('openBoxIfAvailable: failed to get box "$name": $e');
    debugPrint('$st');
    return null;
  }
}
