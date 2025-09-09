import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

final engagementTimeProvider =
    StateNotifierProvider<EngagementTimeNotifier, TimeOfDay>((ref) {
      return EngagementTimeNotifier();
    });

class EngagementTimeNotifier extends StateNotifier<TimeOfDay> {
  EngagementTimeNotifier() : super(_loadInitialTime());
  static const _boxName = 'settings';
  static const _key = 'engagementTime';

  static TimeOfDay _loadInitialTime() {
    final box = Hive.isBoxOpen(_boxName) ? Hive.box(_boxName) : null;
    if (box != null && box.containsKey(_key)) {
      final timeMap = box.get(_key) as Map?;
      if (timeMap != null &&
          timeMap['hour'] != null &&
          timeMap['minute'] != null) {
        return TimeOfDay(hour: timeMap['hour'], minute: timeMap['minute']);
      }
    }
    return const TimeOfDay(hour: 9, minute: 0); // default
  }

  void setTime(TimeOfDay time) {
    final box = Hive.isBoxOpen(_boxName) ? Hive.box(_boxName) : null;
    if (box != null) {
      box.put(_key, {'hour': time.hour, 'minute': time.minute});
      state = time;
    }
  }
}
