import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/models/session.dart';
import 'package:lockin/core/models/task.dart';
import 'package:lockin/features/productivity/productivity_service.dart';

class ProductivityStats {
  ProductivityStats({
    required this.avgDuration,
    required this.clusters,
    required this.streak,
    required this.accuracy,
    required this.fatigue,
    required this.heatmap,
    required this.nudge,
  });
  final double avgDuration;
  final List<int> clusters;
  final int streak;
  final double accuracy;
  final double fatigue;
  final Map<int, int> heatmap;
  final String nudge;
}

final productivityStatsProvider = Provider<ProductivityStats>((ref) {
  final taskBox = Hive.box<Task>('tasks');
  final habitBox = Hive.box<Habit>('habits');
  final sessionBox = Hive.box<Session>('sessions');
  final service = ProductivityService(taskBox, habitBox, sessionBox);
  return ProductivityStats(
    avgDuration: service.getMovingAverageDuration(),
    clusters: service.getFocusTimeClusters(),
    streak: service.getDailyStreak(),
    accuracy: service.getEstimateAccuracy(),
    fatigue: service.getFatigueScore(),
    heatmap: service.getHourlyHeatmap(),
    nudge: service.getNudge(),
  );
});
